--Drago Lustro Misterioso
--Script by XGlitchy30
function c53313934.initial_effect(c) 
	aux.AddOrigPandemoniumType(c)
	--PANDEMONIUM EFFECTS
	--placeholders
	local ph1=Effect.CreateEffect(c)
	ph1:SetLabel(10)
	c:RegisterEffect(ph1)
	local ph2=Effect.CreateEffect(c)
	ph2:SetLabel(20)
	c:RegisterEffect(ph2)
	local ph3=Effect.CreateEffect(c)
	ph3:SetLabel(30)
	c:RegisterEffect(ph3)
	--banish 1 card in the S/T Zone
	local pand1=Effect.CreateEffect(c)
	pand1:SetDescription(aux.Stringid(53313934,0))
	pand1:SetCategory(CATEGORY_REMOVE)
	pand1:SetType(EFFECT_TYPE_QUICK_O)
	pand1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	pand1:SetCode(EVENT_FREE_CHAIN)
	pand1:SetRange(LOCATION_SZONE)
	pand1:SetLabelObject(ph1)
	pand1:SetCondition(aux.PandActCheck)
	pand1:SetCost(c53313934.pandcost)
	pand1:SetTarget(c53313934.pandtg)
	pand1:SetOperation(c53313934.pandop)
	c:RegisterEffect(pand1)
	--banish 1 card your opponent controls
	local pand2=pand1:Clone()
	pand2:SetDescription(aux.Stringid(53313934,1))
	pand2:SetLabelObject(ph2)
	c:RegisterEffect(pand2)
	--banish 1 card from your opponent's GY
	local pand3=pand1:Clone()
	pand3:SetDescription(aux.Stringid(53313934,2))
	pand3:SetLabelObject(ph3)
	c:RegisterEffect(pand3)
	aux.EnablePandemoniumAttribute(c,pand1,pand2,pand3)
	--MONSTER EFFECTS
	--spsummon self
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(53313934,3))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_DESTROYED)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(c53313934.spcon)
	e0:SetTarget(c53313934.sptg)
	e0:SetOperation(c53313934.spop)
	c:RegisterEffect(e0)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53313934,4))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c53313934.thcon)
	e1:SetTarget(c53313934.thtg)
	e1:SetOperation(c53313934.thop)
	c:RegisterEffect(e1)
	--negate and double ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c53313934.discon)
	e2:SetOperation(c53313934.disop)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetCode(EFFECT_DISABLE)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetTargetRange(0,LOCATION_ONFIELD)
	e2x:SetCondition(c53313934.discon)
	c:RegisterEffect(e2x)
	local e2y=Effect.CreateEffect(c)
	e2y:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2y:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2y:SetCode(EVENT_BATTLE_START)
	e2y:SetRange(LOCATION_MZONE)
	e2y:SetCondition(c53313934.bpcon)
	e2y:SetOperation(c53313934.bpop)
	c:RegisterEffect(e2y)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53313934,5))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,50313934)
	e3:SetTarget(c53313934.spsumtg)
	e3:SetOperation(c53313934.spsumop)
	c:RegisterEffect(e3)
end
--filters
function c53313934.pandcostfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c53313934.cfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsSetCard(0xcf6)
end
function c53313934.thfilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c53313934.tgcheck(c,tp,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c53313934.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
function c53313934.spfilter(c,e,tp,att)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:GetLevel()<=6 and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--------PANDEMONIUM EFFECTS--------
--banish effects
function c53313934.pandcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local etype=e:GetLabelObject():GetLabel()
	if not etype or (etype~=10 and etype~=20 and etype~=30) or e:GetHandler():GetFlagEffect(53313934)>0 then return false end
	local ce1=e:GetHandler():IsAbleToRemoveAsCost()
	local ce2=Duel.IsExistingMatchingCard(c53313934.pandcostfilter,tp,LOCATION_MZONE,0,1,nil)
	local ce3=Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil)
	if etype==10 then
		if chk==0 then return ce1 end
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
		e:GetHandler():RegisterFlagEffect(53313934,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE,1)
	elseif etype==20 then
		if chk==0 then return ce2 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c53313934.pandcostfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Remove(g,POS_FACEUP,REASON_COST)
		end
		e:GetHandler():RegisterFlagEffect(53313934,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE,1)
	else
		if chk==0 then return ce3 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Remove(g,POS_FACEUP,REASON_COST)
		end
		e:GetHandler():RegisterFlagEffect(53313934,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE,1)
	end
end
function c53313934.pandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local etype=e:GetLabelObject():GetLabel()
	if not etype or (etype~=10 and etype~=20 and etype~=30) then return false end
	local loc=0
	if etype==10 then
		loc=LOCATION_SZONE
	elseif etype==20 then
		loc=LOCATION_ONFIELD
	else
		loc=LOCATION_GRAVE
	end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,loc,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,loc)
end
function c53313934.pandop(e,tp,eg,ep,ev,re,r,rp)
	local etype=e:GetLabelObject():GetLabel()
	if not etype or (etype~=10 and etype~=20 and etype~=30) then return false end
	local loc=0
	if etype==10 then
		loc=LOCATION_SZONE
	elseif etype==20 then
		loc=LOCATION_ONFIELD
	else
		loc=LOCATION_GRAVE
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,loc,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
--------MONSTER EFFECTS--------
--spsummon self
function c53313934.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c53313934.cfilter,1,nil,tp)
end
function c53313934.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c53313934.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--search
function c53313934.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end
function c53313934.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313934.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c53313934.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c53313934.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--negate and double ATK
function c53313934.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle()
end
function c53313934.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end
function c53313934.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.disfilter1,tp,0,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
function c53313934.bpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and bc and bc:IsControler(1-tp) then
		if Duel.SelectYesNo(tp,aux.Stringid(53313934,6)) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetValue(c:GetAttack()*2)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE)
			c:RegisterEffect(e3)
		end
	end
end
function c53313934.distg(e,c)
	return c~=e:GetHandler()
end
function c53313934.disop2(e,tp,eg,ep,ev,re,r,rp)
	local effect,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	if effect:GetHandler():IsControler(1-e:GetHandlerPlayer()) and bit.band(loc,LOCATION_ONFIELD)~=0 then
		Duel.NegateEffect(ev)
	end
end
--special summon
function c53313934.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53313934.tgcheck(chkc,tp,e) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c53313934.tgcheck,tp,0,LOCATION_MZONE,1,nil,tp,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c53313934.tgcheck,tp,0,LOCATION_MZONE,1,1,nil,tp,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c53313934.spsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c53313934.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttribute())
		if g:GetCount()>0 then
			if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
				local atk=Duel.GetOperatedGroup():GetFirst():GetAttack()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end