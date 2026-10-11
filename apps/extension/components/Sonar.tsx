import "./Sonar.css";

/** Rings around a signal, with a ping travelling outwards. Still when fewer animations are asked. */
export function Sonar({ size }: { size: number }) {
  const radius = size / 2;
  const blip = {
    x: radius + Math.cos(-Math.PI / 3.4) * radius * 0.58,
    y: radius + Math.sin(-Math.PI / 3.4) * radius * 0.58,
  };
  return (
    <svg className="sonar" width={size} height={size} aria-hidden="true">
      <g className="sonar-rings">
        {[1, 2, 3, 4].map((ring) => (
          <circle key={ring} cx={radius} cy={radius} r={(radius * ring) / 4 - 1} />
        ))}
        <line x1={0} y1={radius} x2={size} y2={radius} />
        <line x1={radius} y1={0} x2={radius} y2={size} />
      </g>
      <circle className="sonar-ping" cx={radius} cy={radius} r={radius} />
      <circle className="sonar-signal" cx={radius} cy={radius} r={radius * 0.06} />
      <circle className="sonar-signal sonar-blip" cx={blip.x} cy={blip.y} r={radius * 0.035} />
    </svg>
  );
}
