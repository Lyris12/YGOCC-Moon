--Disstonant Luster Dragon
--Drago Lustro Disstonante
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c) 
	aux.AddOrigPandemoniumType(c)
	--PANDEMONIUM EFFECTS
	--banish 1 card in the S/T Zone
	local pand1=Effect.CreateEffect(c)
	pand1:Desc(0)
	pand1:SetCategory(CATEGORY_REMOVE)
	pand1:SetType(EFFECT_TYPE_QUICK_O)
	pand1:SetCode(EVENT_FREE_CHAIN)
	pand1:SetRange(LOCATION_SZONE)
	pand1:OPT()
	pand1:SetRelevantTimings()
	pand1:SetCondition(aux.PandActCheck)
	pand1:SetCost(aux.DummyCost)
	pand1:SetTarget(s.pandtg)
	pand1:SetOperation(s.pandop)
	c:RegisterEffect(pand1)
	aux.EnablePandemoniumAttribute(c,pand1)
	--MONSTER EFFECTS
	--spsummon self
	local e0=Effect.CreateEffect(c)
	e0:Desc(3)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_DESTROYED)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--battle effects
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetCode(EFFECT_DISABLE)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetTargetRange(0,LOCATION_ONFIELD)
	e2x:SetCondition(s.discon)
	c:RegisterEffect(e2x)
	local e2y=Effect.CreateEffect(c)
	e2y:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2y:SetCode(EVENT_BATTLE_START)
	e2y:SetRange(LOCATION_MZONE)
	e2y:SetCondition(s.bpcon)
	e2y:SetOperation(s.bpop)
	c:RegisterEffect(e2y)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e3:HOPT()
	e3:SetTarget(s.spsumtg)
	e3:SetOperation(s.spsumop)
	c:RegisterEffect(e3)
end
--filters
function s.pandcostfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.cfilter(c)
	return c:IsPreviousSetCard(0xcf6)
end
function s.thfilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tgcheck(c,tp,e)
	local attr=c:GetAttribute()
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and attr>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,c,e,tp,attr)
end
function s.spfilter(c,e,tp,att)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(6) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--------PANDEMONIUM EFFECTS--------
function s.rmfilter1(c)
	return c:IsInBackrow() and c:IsAbleToRemove()
end
function s.pandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mustpay=e:IsCostChecked()
	local b1 = (not mustpay or c:IsAbleToRemoveAsCost()) and Duel.IsExistingMatchingCard(s.rmfilter1,tp,0,LOCATION_SZONE,1,nil)
	local b2 = (not mustpay or Duel.IsExistingMatchingCard(s.pandcostfilter,tp,LOCATION_MZONE,0,1,nil)) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
	local b3 = (not mustpay or Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil)) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	if chk==0 then
		return b1 or b2 or b3
	end
	local opt=aux.Option(tp,id,0,b1,b2,b3)
	if opt==0 then
		if mustpay then
			Duel.Remove(c,POS_FACEUP,REASON_COST)
		end
		local g=Duel.Group(s.rmfilter1,tp,0,LOCATION_SZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_SZONE)
	
	elseif opt==1 then
		if mustpay then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,s.pandcostfilter,tp,LOCATION_MZONE,0,1,1,nil)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_COST)
			end
		end
		local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_ONFIELD)
	
	elseif opt==2 then
		if mustpay then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_COST)
			end
		end
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	end
	Duel.SetTargetParam(opt)
end
function s.pandop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	local tabs = (opt==0) and {s.rmfilter1,LOCATION_SZONE} or (opt==1) and {Card.IsAbleToRemove,LOCATION_ONFIELD} or (opt==2) and {aux.Necro(Card.IsAbleToRemove),LOCATION_GRAVE}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,tabs[1],tp,0,tabs[2],1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
--------MONSTER EFFECTS--------
--spsummon self
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not re or re:GetHandler()~=e:GetHandler()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--negate and double ATK
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and bc and bc:IsControler(1-tp) and c:IsRelateToBattle() and bc:IsRelateToBattle() and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		Duel.Hint(HINT_CARD,tp,id)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(c:GetAttack()*2)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_DISABLE|RESET_PHASE|PHASE_BATTLE)
		c:RegisterEffect(e3)
	end
end
--special summon
function s.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgcheck(chkc,tp,e) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.tgcheck,tp,0,LOCATION_MZONE,1,nil,tp,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgcheck,tp,0,LOCATION_MZONE,1,1,nil,tp,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:GetAttribute()>0 and tc:IsControler(1-tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttribute())
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and g:GetFirst():IsFaceup() and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(1-tp) then
			local atk=Duel.GetOperatedGroup():GetFirst():GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end