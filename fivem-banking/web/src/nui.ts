import { useEffect, useRef } from 'react';

export const isBrowser = !(window as any).invokeNative;

declare function GetParentResourceName(): string;

export async function fetchNui<T>(event: string, data: unknown = {}, mock?: T): Promise<T> {
  if (isBrowser) return mock as T;

  const res = await fetch(`https://${GetParentResourceName()}/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data),
  });
  return res.json();
}

export function useNuiEvent<T>(action: string, handler: (data: T) => void) {
  const saved = useRef(handler);
  saved.current = handler;

  useEffect(() => {
    const listener = (event: MessageEvent<{ action: string; data: T }>) => {
      if (event.data?.action === action) saved.current(event.data.data);
    };
    window.addEventListener('message', listener);
    return () => window.removeEventListener('message', listener);
  }, [action]);
}
