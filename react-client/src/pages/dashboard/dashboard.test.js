import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Dashboard from './index';

describe('Dashboard', () => {
  it('renders the title', () => {
    render(<Dashboard />);
    const dash_text = screen.getByText("Dashboard page");
    expect(dash_text).toBeInTheDocument()
  });
});
