--[[
Eternadir Dragon Elrurynth
Drago Eternadir Elrurynth
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	--Register Activation
	local reg=Effect.CreateEffect(c)
	reg:SetType(EFFECT_TYPE_ACTIVATE)
	reg:SetCode(EVENT_FREE_CHAIN)
	reg:SetRange(LOCATION_HAND)
	reg:SetCost(s.reg)
	c:RegisterEffect(reg)
	--[[You cannot Special Summon non-Xyz Monsters, except by Pendulum Summon.]]
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CAN_FORBIDDEN|EFFECT_FLAG_UNCOPYABLE)
	p1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(1,0)
	p1:SetTarget(s.splimit)
	c:RegisterEffect(p1)
	--[[During your Main Phase, if this card was activated this turn: You can add 1 "Eternadir" Spell/Trap from your Deck to your hand.]]
	local p2=Effect.CreateEffect(c)
	p2:Desc(0)
	p2:SetCategory(CATEGORIES_SEARCH)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetRange(LOCATION_PZONE)
	p2:HOPT()
	p2:SetFunctions(s.discon,nil,s.distg,s.disop)
	c:RegisterEffect(p2)
	--Must be Pendulum Summoned.
	aux.EnableReviveLimitPendulumSummonable(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit_self)
	c:RegisterEffect(e0)
	--If this card is Tributed: You can target 1 card on the field; return it to the hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:HOPT()
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end

--P1
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and (sumtype&SUMMON_TYPE_PENDULUM)~=SUMMON_TYPE_PENDULUM
end

--P2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id)
end
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_ETERNADIR) and c:IsAbleToHand()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

--E0
function s.splimit_self(e,se,sp,st)
	return (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

--E1
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end