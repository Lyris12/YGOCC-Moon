local m=8886672
local cm=_G["c"..m]

--Dark Child's Lament
function cm.initial_effect(c)
	--  runcost
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0a:SetCode(EVENT_PREDRAW)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e0a:SetOperation(cm.start)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0b:SetCode(EVENT_PREDRAW)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetCountLimit(1)
	e0b:SetOperation(cm.start2)
	c:RegisterEffect(e0b)
--  Passive Boost
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_UPDATE_ATTACK)
	pe1:SetRange(LOCATION_EXTRA)
	pe1:SetTargetRange(LOCATION_MZONE,0)
	pe1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	pe1:SetCondition(cm.pe1condition)
	pe1:SetValue(300)
	c:RegisterEffect(pe1)
	local pe2=pe1:Clone()
	pe2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(pe2)

--  Turn Modifiers

	-- Herald of White Madness
	local howm1=Effect.CreateEffect(c)
	howm1:SetDescription(aux.Stringid(m,0))
	howm1:SetType(EFFECT_TYPE_IGNITION)
	howm1:SetRange(LOCATION_EXTRA)
	howm1:SetCondition(cm.howmcon)
	howm1:SetTarget(cm.howmtg)
	howm1:SetOperation(cm.howmop)
	c:RegisterEffect(howm1)
	
	-- Shadows Call
	local sdc=Effect.CreateEffect(c)
	sdc:SetDescription(aux.Stringid(m,1))
	sdc:SetType(EFFECT_TYPE_IGNITION)
	sdc:SetRange(LOCATION_EXTRA)
	sdc:SetCountLimit(1)
	sdc:SetCondition(cm.sdccon)
	sdc:SetTarget(cm.sdctg)
	sdc:SetOperation(cm.sdcop)
	c:RegisterEffect(sdc)

--  Gained Effects

	-- Sanctuary of Darkness
	local sod1=Effect.CreateEffect(c)
	sod1:SetDescription(aux.Stringid(m,2))
	sod1:SetCategory(CATEGORY_ATKCHANGE)
	sod1:SetType(EFFECT_TYPE_IGNITION)
	sod1:SetRange(LOCATION_EXTRA)
	sod1:SetCondition(cm.sod1con)
	sod1:SetTarget(cm.sod1tg)
	sod1:SetOperation(cm.sod1op)
	c:RegisterEffect(sod1)

	-- Aorg Effect
	local cp2=Effect.CreateEffect(c)
	cp2:SetDescription(aux.Stringid(m,3))
	cp2:SetCategory(CATEGORY_ATKCHANGE)
	cp2:SetType(EFFECT_TYPE_IGNITION)
	cp2:SetRange(LOCATION_EXTRA)
	cp2:SetCondition(cm.aorg1con)
	cp2:SetTarget(cm.aorg1tg)
	cp2:SetOperation(cm.aorg1op)
	c:RegisterEffect(cp2)
end


-----------------
--Start Effects--
-----------------

function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
end

function cm.start2(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFlagEffect(tp,88866601) < 1) then
		Duel.RegisterFlagEffect(tp,88866601,RESET_DISABLE,0,1)
	end
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=5
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
end


-------------------
-- Passive Boost --
-------------------

function cm.pe1condition(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=30
	return corruption>=threshold
end

-------------------
-- Turn Modifier --
-------------------

function cm.howmcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	return echos>=cost
end

function cm.howmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=10
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.howmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cm.howmopcon)
	e1:SetTarget(cm.howmoptg)
	e1:SetOperation(cm.howmopop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function cm.howmopcfilter(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end

function cm.howmopcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.howmopcfilter,1,nil)
end

function cm.howmopthfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_RELEASE) and c:IsControler(tp) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FAIRY)
end

function cm.howmoptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	if chkc then return mat:IsContains(chkc) and cm.howmopthfilter(chkc,e,tp) end
	if chk==0 then return mat:IsExists(cm.howmopthfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
end

function cm.howmopop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	local g=mat:FilterSelect(tp,cm.howmopthfilter,1,1,nil,e,tp)
	local tc=g
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=20
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc) 
end

--shadow's grasp

function cm.sdccon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	return echos>=cost
end

function cm.sdctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=10
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.sdcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(cm.reptg)
	e1:SetValue(cm.repval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function cm.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:GetDestination()==LOCATION_DECK and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end

function cm.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and eg:IsExists(cm.repfilter,1,nil,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
		local g=eg:Filter(cm.repfilter,nil,tp)
		local ct=g:GetCount()
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			g=g:Select(tp,1,ct,nil)
		end
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_DECK_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_HAND)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(m,RESET_EVENT+0x1de0000+RESET_PHASE+PHASE_END,0,1)
			tc=g:GetNext()
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_TO_HAND)
		e1:SetCountLimit(1)
		e1:SetCondition(cm.thcon)
		e1:SetOperation(cm.thop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		return true
	else return false end
end

function cm.repval(e,c)
	return false
end

function cm.thfilter(c)
	return c:GetFlagEffect(m)~=0
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.thfilter,1,nil)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cm.thfilter,nil)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=20
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc) 
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end


--------------------
-- Gained Effects --
--------------------

-- Sanctuary of Darkness
function cm.sod1con(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	return echos>=cost
end

function cm.sod1tgfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FAIRY)
end

function cm.sod1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--standard target--
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.sod1tgfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(cm.sod1tgfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINSTMSG_FACEUP)
	Duel.SelectTarget(tp,sod1tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
--corruption--
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	local new= echos-cost
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=20
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.sod1op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,2))
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_FACEDOWN))
	e1:SetValue(1)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	tc:RegisterEffect(e2)
	if not tc:IsType(TYPE_EFFECT) then
		local auxe1=Effect.CreateEffect(e:GetHandler())
		auxe1:SetType(EFFECT_TYPE_SINGLE)
		auxe1:SetCode(EFFECT_ADD_TYPE)
		auxe1:SetValue(TYPE_EFFECT)
		auxe1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(auxe1,true)
	end
end

-- Angel Organziation effect
--condition--
function cm.aorg1con(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	return echos>=cost
end

--target filter--
function cm.aorg1tgfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FAIRY)
end

-------------------
--target function--
-------------------

function cm.aorg1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--standard target--
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.aorg1tgfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(cm.aorg1tgfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINSTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.aorg1tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
--corruption--
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	local new= echos-cost
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=20
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end


--effect--
function cm.aorg1op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,3))
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(cm.aorg1cost)
	e1:SetTarget(cm.aorg1target)
	e1:SetOperation(cm.aorg1operation)
	tc:RegisterEffect(e1)
	if not tc:IsType(TYPE_EFFECT) then
		local auxe1=Effect.CreateEffect(e:GetHandler())
		auxe1:SetType(EFFECT_TYPE_SINGLE)
		auxe1:SetCode(EFFECT_ADD_TYPE)
		auxe1:SetValue(TYPE_EFFECT)
		auxe1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(auxe1,true)
	end
end

--------------------
--inhereted effect--
--------------------

function cm.aorg1costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end

function cm.aorg1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.aorg1costfilter,tp,LOCATION_DECK,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.aorg1costfilter,tp,LOCATION_DECK,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end

function cm.aorg1filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and not (c:GetAttack()==c:GetDefense()) and not c:IsType(TYPE_LINK)
end

function cm.aorg1target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cm.aorg1filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.aorg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.aorg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function cm.aorg1operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end

