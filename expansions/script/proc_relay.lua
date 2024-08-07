--coded by Lyris
--リレー召喚
--Not yet finalized values
--Custom constants
TYPE_RELAY		=0x20000000000
TYPE_CUSTOM		=TYPE_CUSTOM|TYPE_RELAY
CTYPE_RELAY		=0x200
CTYPE_CUSTOM	=CTYPE_CUSTOM|CTYPE_RELAY

--Custom Type Table
Auxiliary.Relays={} --number as index = card

--overwrite functions
local get_type, get_orig_type, get_prev_type_field =
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Relays[c] then
		tpe=tpe|TYPE_RELAY
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Relays[c] then
		tpe=tpe|TYPE_RELAY
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Relays[c] then
		tpe=tpe|TYPE_RELAY
	end
	return tpe
end

--Custom Functions
function Auxiliary.AddOrigRelayType(c)
	table.insert(Auxiliary.Relays,c)
	Auxiliary.Customs[c]=true
	Auxiliary.Relays[c]=aux.TRUE
end
function Auxiliary.AddRelayProc(c)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_BE_PRE_MATERIAL)
	e1:SetOperation(function(e) Auxiliary.RelayPass(c,e:GetHandler():GetReasonCard()) end)
	c:RegisterEffect(e1)
	if not relay_check then
		relay_check=true
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BE_PRE_MATERIAL)
		e2:SetOperation(function(e,tp,eg) for tc in aux.Next(eg) do if tc:GetReasonCard()==c then Auxiliary.RelayPass(tc,c) end end end)
		Duel.RegisterEffect(e2,0)
	end
end
function Auxiliary.RelayPass(fc,tc)
	for _,te in pairs(global_card_effect_table[fc]) do
		if aux.GetValueType(te)=="Effect" and (te:IsHasType(0xfc0) or te:GetType()==EFFECT_TYPE_SINGLE)
			and not te:IsHasProperty(EFFECT_FLAG_INITIAL+EFFECT_FLAG_UNCOPYABLE) then
			local res=te:GLGetReset()
			if te:GetOwner()~=fc or te:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE) or (res and res&RESET_DISABLE==0) then
				local ef=te:Clone()
				tc:RegisterEffect(ef,true)
			end
		end
	end
end
