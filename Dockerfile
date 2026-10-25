FROM rust:1.81.0 AS builder

RUN rustup target add wasm32-unknown-unknown

RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall trunk@0.21.14 -y

WORKDIR /app

COPY . .

RUN cd frontend && trunk build --release
RUN cd server && cargo build --release

# The frontend is embedded in the server binary (include_dir), so the runtime
# image only needs the binary.
FROM debian:bookworm-slim

COPY --from=builder /app/target/release/server /usr/local/bin/server

EXPOSE 3000

CMD ["server"]
