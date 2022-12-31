local m=8886670
local cm=_G["c"..m]

--Void Acceptence
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
--------------------------
-- CORRUPTION POSITIVES --
--------------------------
--==============--
--Turn Modifiers--
--==============--
--  Blood Drinker
	local bd1=Effect.CreateEffect(c)
	bd1:SetDescription(aux.Stringid(m,5))
	bd1:SetType(EFFECT_TYPE_IGNITION)
	bd1:SetRange(LOCATION_EXTRA)
	bd1:SetCountLimit(1)
	bd1:SetCondition(cm.bdcon)
	bd1:SetTarget(cm.bdtg)
	bd1:SetOperation(cm.bdop)
	c:RegisterEffect(bd1)

----------------------------------
--Bulwark of the Infinite Shadow--
----------------------------------
	local bofis1=Effect.CreateEffect(c)
	bofis1:SetDescription(aux.Stringid(m,6))
	bofis1:SetType(EFFECT_TYPE_IGNITION)
	bofis1:SetRange(LOCATION_EXTRA)
	bofis1:SetCondition(cm.botiscon)
	bofis1:SetTarget(cm.botistg)
	bofis1:SetOperation(cm.botisop)
	c:RegisterEffect(bofis1)
--==============--
--Gained Effects--
--==============--
--  Void Ritual
	local cp1=Effect.CreateEffect(c)
	cp1:SetDescription(aux.Stringid(m,3))
	cp1:SetCategory(CATEGORY_ATKCHANGE)
	cp1:SetType(EFFECT_TYPE_IGNITION)
	cp1:SetRange(LOCATION_EXTRA)
	cp1:SetCondition(cm.vrcon)
	cp1:SetTarget(cm.vrtg)
	cp1:SetOperation(cm.vrop)
	c:RegisterEffect(cp1)
--  Hide in Shadows
	local cp2=Effect.CreateEffect(c)
	cp2:SetDescription(aux.Stringid(m,4))
	cp2:SetCategory(CATEGORY_ATKCHANGE)
	cp2:SetType(EFFECT_TYPE_IGNITION)
	cp2:SetRange(LOCATION_EXTRA)
	cp2:SetCondition(cm.hiscon)
	cp2:SetTarget(cm.histg)
	cp2:SetOperation(cm.hisop)
	c:RegisterEffect(cp2)
end

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
-----------------
--Blood Drinker--
-----------------
function cm.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=30
	return echos>=cost
end

function cm.bdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=30
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=5
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.bdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(cm.bdopcon)
	e1:SetOperation(cm.bdopop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function cm.bdopcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:GetFirst():IsControler(tp)
end

function cm.bdopop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,ev,REASON_EFFECT)
end

----------------------------------
--Bulwark of the Infinite Shadow--
----------------------------------
function cm.botiscon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=40
	return echos>=cost
end

function cm.botistg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=40
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=50
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.botisop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(cm.botisopop)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1+PHASE_MAIN2+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function cm.botisopop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.SetChainLimit(aux.FALSE)
end


---------------
--VOID RITUAL--
---------------

function cm.vrcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	return echos>=cost
end

function cm.vrfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end

function cm.vrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.vrfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(cm.vrfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINSTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.vrfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
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

function cm.vrop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	tc:EnableCounterPermit(0x8666)
	tc:SetCounterLimit(0x8666,20)
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,3))
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
	local e0=Effect.CreateEffect(tc)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(aux.chainreg)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e0,true)
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(cm.vracop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(tc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.vratkval)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2,true)
	local e3=Effect.CreateEffect(tc)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CUSTOM+88866601)
	e3:SetCost(cm.vrcost)
	e3:SetOperation(cm.vrstackop)
	tc:RegisterEffect(e3)
	if not tc:IsType(TYPE_EFFECT) then
		local auxe1=Effect.CreateEffect(e:GetHandler())
		auxe1:SetType(EFFECT_TYPE_SINGLE)
		auxe1:SetCode(EFFECT_ADD_TYPE)
		auxe1:SetValue(TYPE_EFFECT)
		auxe1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(auxe1,true)
	end
end

function cm.vracop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(1)>0 then
		c:AddCounter(0x8666,1)
		if c:GetCounter(0x8666)>=20 then
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+88866601,re,0,0,p,0)
		end
	end
end

function cm.vratkval(e,c)
	return c:GetCounter(0x8666)*100
end

function cm.vrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler() and e:GetHandler():GetCounter(0x8666)>=20 end 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	e:GetHandler():RemoveCounter(tp,0x8666,20,REASON_COST)
end

function cm.vrstackop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local dg=Group.CreateGroup()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	Duel.Destroy(dg,REASON_EFFECT)
end

-- Hide in Shadows

function cm.hiscon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=50
	return echos>=cost
end

function cm.hisfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end

function cm.histg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.hisfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(cm.hisfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINSTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.hisfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=50
	local new= echos-cost
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=30
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.hisop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,4))
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
end
