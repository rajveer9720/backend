declare module 'express-ipfilter' {
  export interface IpFilterOptions {
    mode?: 'allow' | 'deny';
    logLevel?: string;
    log?: boolean;
    allowedHeaders?: string[];
    excluding?: string[];
    detectIp?: (req: any) => string;
  }

  export function IpFilter(
    ips: string | string[],
    options?: IpFilterOptions
  ): (req: any, res: any, next: any) => void;
}
