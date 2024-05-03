import { randomBytes, scrypt, timingSafeEqual } from "crypto";
import { promisify } from "util";

const scryptAsync = promisify(scrypt);

export async function hashPassword(password: string) {
  const salt = randomBytes(512).toString('hex');
  const buffer = (await scryptAsync(password, salt, 512)) as Buffer;
  return `${buffer.toString('hex')}.${salt}`;
}

export async function comparePassword(
  storedPassword: string,
  suppliedPassword: string,
): Promise<Boolean> {
  const [hashPassword, salt] = storedPassword.split('.');
  const hashedPasswordBuffer = Buffer.from(hashPassword, 'hex');
  const suppliedPasswordBuffer = (await scryptAsync(
    suppliedPassword,
    salt,
    512,
  )) as Buffer;
  return timingSafeEqual(hashedPasswordBuffer, suppliedPasswordBuffer);
}