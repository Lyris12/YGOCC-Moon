--created & coded by Lyris, art from Cardfight!! Vanguard V's "Masked Magician, Harri"
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xc74),4,2,nil,nil,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function() return Duel.GetTurnPlayer()==c:GetControler() end)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(function(e) e:SetLabel(100) return true end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,1)
	if c:IsRelateToEffect(e) and #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Overlay(c,g)
	end
end
function s.filter(c,tp)
	return c:IsLevelAbove(1) and c:IsCanOverlay(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return c:CheckRemoveOverlayCard(tp,2,REASON_COST) and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
	end
	e:SetLabel(c:RemoveOverlayCard(tp,2,Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_MZONE,nil,tp)+1,REASON_COST))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()-1
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.Overlay(c,Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,ct,ct,nil,tp))
end
