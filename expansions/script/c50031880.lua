function c50031880.initial_effect(c)
  aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsSetCard,0x485a),1)
	c:EnableReviveLimit()
			--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50031880,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50031880)
	e1:SetCondition(c50031880.thcon)
	e1:SetTarget(c50031880.thtg)
	e1:SetOperation(c50031880.thop)
	c:RegisterEffect(e1)
		local e5=e1:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e6)
		--local e2=Effect.CreateEffect(c)
	--e2:SetType(EFFECT_TYPE_SINGLE)
	--e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	--e2:SetCode(EFFECT_CHANGE_CODE)
	--e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	--e2:SetValue(500311028)
	--c:RegisterEffect(e2)
		--  local e3=Effect.CreateEffect(c)
--  e3:SetType(EFFECT_TYPE_SINGLE)
--  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
--  e3:SetCode(EFFECT_ADD_TYPE)
--  e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
--  e3:SetValue(TYPE_NORMAL)
--  c:RegisterEffect(e3)
	--remove
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(50031880,1))
	e0:SetCategory(CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,52068433)
	e0:SetCondition(c50031880.remcon)
	e0:SetTarget(c50031880.remtg)
	e0:SetOperation(c50031880.remop)
	c:RegisterEffect(e0)
		--cannot special summon
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.synlimit)
	c:RegisterEffect(e3)
	end
	function c50031880.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function c50031880.remfilter2(c)
	return  c:IsAbleToRemove()
end
function c50031880.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,30459350)
		and Duel.IsExistingMatchingCard(c50031880.remfilter2,tp,LOCATION_ONFIELD,0,2,nil,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
end
function c50031880.remop(e,tp,eg,ep,ev,re,r,rp)
local g1=Duel.GetMatchingGroup(c50031880.remfilter2,tp,LOCATION_ONFIELD,0,e:GetHandler())
local g2=Duel.GetMatchingGroup(c50031880.remfilter2,tp,0,LOCATION_ONFIELD,nil)
local ct=math.min(g1:GetCount(),g2:GetCount())
if ct==0 then return end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
local sg=g1:Select(tp,1,ct,nil)
ct=sg:GetCount()
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
sg:Merge(g2:Select(tp,ct,ct,nil))
Duel.HintSelection(sg)
Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	local ct=sg:FilterCount(c50031880.remfilter2,nil,1-tp)
		local ct=sg:FilterCount(c50031880.remfilter2,nil,tp)
if ct>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct*100,REASON_EFFECT,true) 
		Duel.Damage(tp,ct*100,REASON_EFFECT,true)
		Duel.RDComplete()
end
end
function c50031880.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c50031880.thfilter(c)
	return c:IsSetCard(0x485a) and c:IsAbleToHand()
end
function c50031880.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and c50031880.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c50031880.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c50031880.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c50031880.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end