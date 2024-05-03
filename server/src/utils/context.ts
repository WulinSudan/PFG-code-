export interface Context {
  req: any;
}

export function createContext(req: any) {
  return {
    ...req
  };
}