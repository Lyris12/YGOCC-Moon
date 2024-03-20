--[[
Vesta, Royal Knight of Ichyaltas
Vesta, Cavaliere Reale di Ichyaltas
Card Author: Zerry
Original Script by: Seinector Phantasmagoria
Updated by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[You can Special Summon this card (from your hand or GY) by Tributing 1 face-up "Ichyaltas" monster you control, except "Vesta, Royal Knight of Ichyaltas".]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this card is Tributed: You can target 1 "Ichyaltas" card in your GY; add it to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:HOPT()
	e2:SetTarget(s.rltg)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_ICHYALTAS) and not c:IsCode(id)
		and Duel.GetMZoneCount(tp,c)>0
end
function s.spcon(e,c)
	if c==nil then return true end
	if c:IsLocation(LOCATION_GRAVE) and c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_SPSUMMON,false,nil,tp)
	Duel.Release(g,REASON_SPSUMMON)
end

--E2
function s.filter(c)
	return c:IsSetCard(ARCHE_ICHYALTAS) and c:IsAbleToHand()
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end