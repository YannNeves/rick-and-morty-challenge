export type LocationSummary = {
  id: number;
  name: string;
  type: string;
  dimension: string;
  residentCount: number;
};

export type Location = LocationSummary & {
  residentIds: number[];
};

export type LocationListFilters = {
  page: number;
  name?: string;
  type?: string;
  dimension?: string;
};

export type LocationPage = {
  page: number;
  totalPages: number;
  totalItems: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
  locations: Location[];
};

export type LocationListResult = Omit<LocationPage, "locations"> & {
  locations: LocationSummary[];
};
