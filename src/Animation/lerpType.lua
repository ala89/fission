local function lerpType(from: any, to: any, ratio: number): any
	local typeName = typeof(from)

	if typeof(to) == typeName then
		if typeName == "number" then
			return (to - from) * ratio + from
		elseif typeName == "boolean" then
			return ratio > 0
		elseif typeName == "CFrame" then
			return from:Lerp(to, ratio)
		elseif typeName == "Color3" then
            return from:Lerp(to, ratio)
		elseif typeName == "ColorSequenceKeypoint" then
			return ColorSequenceKeypoint.new(
                (to.Time - from.Time) * ratio + from.Time,
                from:Lerp(to, ratio)
            )
		elseif typeName == "DateTime" then
			return DateTime.fromUnixTimestampMillis(
                (to.UnixTimestampMillis - from.UnixTimestampMillis) * ratio + from.UnixTimestampMillis
            )
		elseif typeName == "NumberRange" then
			return NumberRange.new(
				(to.Min - from.Min) * ratio + from.Min,
				(to.Max - from.Max) * ratio + from.Max
			)
		elseif typeName == "NumberSequenceKeypoint" then
			return NumberSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				(to.Value - from.Value) * ratio + from.Value,
				(to.Envelope - from.Envelope) * ratio + from.Envelope
			)
		elseif typeName == "PhysicalProperties" then
			return PhysicalProperties.new(
				(to.Density - from.Density) * ratio + from.Density,
				(to.Friction - from.Friction) * ratio + from.Friction,
				(to.Elasticity - from.Elasticity) * ratio + from.Elasticity,
				(to.FrictionWeight - from.FrictionWeight) * ratio + from.FrictionWeight,
				(to.ElasticityWeight - from.ElasticityWeight) * ratio + from.ElasticityWeight
			)
		elseif typeName == "Ray" then
			return Ray.new(
				from.Origin:Lerp(to.Origin, ratio),
				from.Direction:Lerp(to.Direction, ratio)
			)
		elseif typeName == "Rect" then
			return Rect.new(
				from.Min:Lerp(to.Min, ratio),
				from.Max:Lerp(to.Max, ratio)
			)
		elseif typeName == "Region3" then
			local position = from.CFrame.Position:Lerp(to.CFrame.Position, ratio)
			local size = from.Size:Lerp(to.Size, ratio)
			return Region3.new(position - size / 2, position + size / 2)
		elseif typeName == "Region3int16" then
			return Region3int16.new(
				Vector3int16.new(
					(to.Min.X - from.Min.X) * ratio + from.Min.X,
					(to.Min.Y - from.Min.Y) * ratio + from.Min.Y,
					(to.Min.Z - from.Min.Z) * ratio + from.Min.Z
				),
				Vector3int16.new(
					(to.Max.X - from.Max.X) * ratio + from.Max.X,
					(to.Max.Y - from.Max.Y) * ratio + from.Max.Y,
					(to.Max.Z - from.Max.Z) * ratio + from.Max.Z
				)
			)
		elseif typeName == "UDim" then
			return UDim.new(
				(to.Scale - from.Scale) * ratio + from.Scale,
				(to.Offset - from.Offset) * ratio + from.Offset
			)
		elseif typeName == "UDim2" then
			return from:Lerp(to, ratio)
		elseif typeName == "Vector2" then
			return from:Lerp(to, ratio)
		elseif typeName == "Vector2int16" then
			return Vector2int16.new(
				(to.X - from.X) * ratio + from.X,
				(to.Y - from.Y) * ratio + from.Y
			)
		elseif typeName == "Vector3" then
			return from:Lerp(to, ratio)
		elseif typeName == "Vector3int16" then
			return Vector3int16.new(
				(to.X - from.X) * ratio + from.X,
				(to.Y - from.Y) * ratio + from.Y,
				(to.Z - from.Z) * ratio + from.Z
			)
		end
	end

	if ratio < 0.5 then
		return from
	else
		return to
	end
end

return lerpType