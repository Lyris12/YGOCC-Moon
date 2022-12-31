--Altair Saggezza, Nobile Uccello d'Inverno
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	aux.AddSynchroMixProcedure(c,aux.NonTuner(s.mfilter),nil,nil,s.tunerfilter,1,99,s.gcheck)
	aux.EnableChangeCode(c,400001,LOCATION_MZONE+LOCATION_GRAVE)
	--act qp in hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(2)
	e1:SetCondition(s.handcon)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x246))
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(aux.SynchroSummonedCond)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR)
end
function s.tunerfilter(c)
	if c:IsSynchroType(TYPE_TUNER) then return true end
	if c:IsSetCard(0x246) and c:IsRace(RACE_SPELLCASTER) then
		c:RegisterFlagEffect(id,0,EFFECT_FLAG_IGNORE_IMMUNE,1)
		return true
	end
	return false
end
function s.gcheck(g)
	local res = not g:IsExists(Card.HasFlagEffect,2,nil,id)
	for tc in aux.Next(g) do
		if tc:HasFlagEffect(id) then
			tc:ResetFlagEffect(id)
		end
	end
	return res
end

function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.thfilter(c)
	return c:IsSetCard(0x246) and c:GetType()&(TYPE_SPELL+TYPE_QUICKPLAY)==TYPE_SPELL+TYPE_QUICKPLAY and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end