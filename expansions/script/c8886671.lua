local m=8886671
local cm=_G["c"..m]

--Dragon's Rage
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

	--  Passive Effect
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_UPDATE_ATTACK)
	pe1:SetRange(LOCATION_EXTRA)
	pe1:SetTargetRange(LOCATION_MZONE,0)
	pe1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	pe1:SetCondition(cm.pe1condition)
	pe1:SetValue(300)
	c:RegisterEffect(pe1)
	local pe2=pe1:Clone()
	pe2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(pe2)
	local pe3=Effect.CreateEffect(c)
	pe3:SetType(EFFECT_TYPE_FIELD)
	pe3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	pe3:SetCode(EFFECT_CANNOT_ACTIVATE)
	pe3:SetRange(LOCATION_EXTRA)
	pe3:SetTargetRange(0,1)
	pe3:SetCondition(cm.pe3actcon)
	pe3:SetValue(1)
	c:RegisterEffect(pe3)
	-- destruction force

		local f1,f2,f3,f4,f5=Duel.SendtoGrave,Duel.SendtoHand,Duel.SendtoDeck,Duel.SendtoExtraP,Duel.Remove
	Duel.SendtoGrave=function(tg,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do if tc:IsHasEffect(id) then ct=ct+Duel.Destroy(tc,r)
		else ct=ct+f1(tc,r) end end
		return ct
	end
	Duel.SendtoHand=function(tg,tp,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if tp==tc:GetControler() then ct=ct+Duel.Destroy(tc,r,LOCATION_HAND)
				else ct=ct+f2(tc,tp,r|REASON_DESTROY)
			end
			else ct=ct+f2(tc,tp,r) end
		end
		return ct
	end
	Duel.SendtoDeck=function(tg,tp,seq,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then ct=ct+Duel.Destroy(tc,r,LOCATION_DECK+seq<<16)
				else ct=ct+f3(tc,tp,seq,r|REASON_DESTROY) end
			else ct=ct+f3(tc,tp,seq,r) end
		end
		return ct
	end
	Duel.Remove=function(tg,pos,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if pos&POS_FACEUP>0 then ct=ct+Duel.Destroy(tc,r,LOCATION_REMOVED)
				else ct=ct+f5(tc,pos,r|REASON_DESTROY)
			end
			else ct=ct+f5(tc,pos,r) end
		end
		return ct
	end
	Duel.SendtoExtraP=function(tg,tp,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then ct=ct+Duel.Destroy(tc,r,LOCATION_EXTRA)
				else ct=ct+f4(tc,tp,r|REASON_DESTROY) end
			else ct=ct+f4(tc,tp,r) end
		end
		return ct
	end
	local col=Effect.CreateEffect(c)
	col:SetType(EFFECT_TYPE_IGNITION)
	col:SetRange(LOCATION_EXTRA)
	col:SetDescription(aux.Stringid(m,0))
	col:SetCountLimit(1)
	col:SetCondition(cm.colcon)
	col:SetTarget(cm.coltg)
	col:SetOperation(cm.colop)
	c:RegisterEffect(col)
--  Void Regneration
	local vreg=Effect.CreateEffect(c)
	vreg:SetDescription(aux.Stringid(m,1))
	vreg:SetCategory(CATEGORY_DRAW)
	vreg:SetType(EFFECT_TYPE_IGNITION)
	vreg:SetRange(LOCATION_EXTRA)
	vreg:SetCountLimit(1)
	vreg:SetCondition(cm.vregcon)
	vreg:SetTarget(cm.vregtg)
	vreg:SetOperation(cm.vregop)
	c:RegisterEffect(vreg)
	if cm.counter==nil then
		cm.counter=true
		cm[0]=0
		cm[1]=0
		local vreg2=Effect.CreateEffect(c)
		vreg2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		vreg2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		vreg2:SetOperation(cm.resetcount)
		Duel.RegisterEffect(vreg2,0)
		local vreg3=Effect.CreateEffect(c)
		vreg3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		vreg3:SetCode(EVENT_RELEASE)
		vreg3:SetOperation(cm.addcount)
		Duel.RegisterEffect(vreg3,0)
		local vreg4=Effect.CreateEffect(c)
		vreg4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		vreg4:SetCode(EVENT_DISCARD)
		vreg4:SetOperation(cm.addcount)
		Duel.RegisterEffect(vreg4,0)
	end
--	Wrath of the Dragonlords
	local wotdl=Effect.CreateEffect(c)
	wotdl:SetDescription(aux.Stringid(m,2))
	wotdl:SetCategory(CATEGORY_ATKCHANGE)
	wotdl:SetType(EFFECT_TYPE_IGNITION)
	wotdl:SetRange(LOCATION_EXTRA)
	wotdl:SetCountLimit(1)
	wotdl:SetCondition(cm.wotdlcon)
	wotdl:SetTarget(cm.wotdltg)
	wotdl:SetOperation(cm.wotdlop)
	c:RegisterEffect(wotdl)
end


-- start

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

-- passive

function cm.pe1condition(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=30
	return corruption>=threshold
end


function cm.pe3actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tp = e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=60
	return (a and cm.pe3cfilter(a,tp)) or (d and cm.pe3cfilter(d,tp)) and corruption>=threshold
end

function cm.pe3cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControler(tp)
end
--Curse of Lightning--

function cm.colcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=50
	return echos>=cost
end

function cm.coltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
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

function cm.colop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(m)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsRace(RACE_DRAGON)))
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

--void regeneration


function cm.vregcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=30
	return echos>=cost
end

function cm.vregtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=30
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=20
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)   
end

function cm.vregop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(cm.vregopdroperation)
	Duel.RegisterEffect(e1,tp)
end

function cm.vregopdroperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Draw(tp,cm[tp],REASON_EFFECT)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc= 15 * cm[tp]
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
end

function cm.resetcount(e,tp,eg,ep,ev,re,r,rp)
	cm[0]=0
	cm[1]=0
end

function cm.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local pl=tc:GetPreviousLocation()
		if pl==LOCATION_MZONE and tc:GetPreviousRaceOnField()==RACE_DRAGON then
			local p=tc:GetReasonPlayer()
			cm[p]=cm[p]+1
		elseif pl==LOCATION_HAND and tc:IsType(TYPE_MONSTER) and tc:GetOriginalRace()==RACE_DRAGON then
			local p=tc:GetPreviousControler()
			cm[p]=cm[p]+1
		end
		tc=eg:GetNext()
	end
end

--Wrath of the Dragonlords

function cm.wotdlcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=40
	return echos>=cost
end

function cm.wotdlfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsRace(RACE_DRAGON) and (c:IsLevelAbove(7) or c:IsRankAbove(7))
end

function cm.wotdltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.wotdlfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(cm.wotdlfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINSTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.wotdlfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=40
	local new= echos-cost
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=30
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.wotdlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,2))
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
		local e2=Effect.CreateEffect(tc)
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e2:SetReset(RESETS_STANDARD)
		e2:SetTarget(cm.destg)
		e2:SetOperation(cm.desop)
		tc:RegisterEffect(e2,true)
end

function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		Duel.Destroy(tg,REASON_EFFECT)
		local corruption=Duel.GetFlagEffectLabel(tp,88866601)
		local inc=15
		local newc= corruption+inc
		Duel.SetFlagEffectLabel(tp,88866601,newc)
	end
end