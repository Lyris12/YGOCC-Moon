--created & coded by Lyris, art by CherryKagura0w0 of DeviantArt
--焔聖剣士
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,4,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetCost(function() return c:GetEquipGroup():IsExists(Card.IsReleasable,2,nil)
		or c:CheckRemoveOverlayCard(tp,2,REASON_COST) end)
	e2:SetOperation(function() if Duel.SelectOption(tp,HINTMSG_REMOVEXYZ,HINTMSG_RELEASE)==0 then
		c:RemoveOverlayCard(tp,2,2,REASON_COST)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=c:GetEquipGroup():FilterSelect(tp,Card.IsReleasable,2,2,nil)
		Duel.Release(g,REASON_COST)
	end end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.filter(c,ec)
	return (not c:IsType(TYPE_EQUIP) or c:CheckEquipTarget(ec)) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,c) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,c):GetFirst()
		if not tc or not Duel.Equip(tp,tc,c) then Duel.SendtoGrave(c,REASON_RULE) return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,ec) return ec==tc end)
		tc:RegisterEffect(e1)
	else
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
