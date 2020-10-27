-- Corruption Effects --
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
local m=8886660
local cm=_G["c"..m]
function cm.initial_effect(c)
-------------------------------
-- INITIATION + CORE EFFECTS --
-------------------------------
--  Label Effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1)
	e0:SetCondition(cm.startcon)
	e0:SetOperation(cm.start)
	c:RegisterEffect(e0)
--[[  Test effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.testcon)
	e1:SetTarget(cm.testtg)
	e1:SetOperation(cm.testop)
--  c:RegisterEffect(e1)]]--
--  Horrifc Echo Check
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(m,1))
	e2a:SetCategory(CATEGORY_DAMAGE)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetRange(LOCATION_EXTRA)
	e2a:SetCountLimit(3)
	e2a:SetTarget(cm.horrific_echo_check_tg)
	e2a:SetOperation(cm.horrific_echo_check_op)
	c:RegisterEffect(e2a)
--  Corruption Check
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(m,2))
	e2b:SetCategory(CATEGORY_DAMAGE)
	e2b:SetType(EFFECT_TYPE_IGNITION)
	e2b:SetRange(LOCATION_EXTRA)
	e2b:SetCountLimit(3)
	e2b:SetTarget(cm.corruption_check_tg)
	e2b:SetOperation(cm.corruption_check_op)
	c:RegisterEffect(e2b)
--  Resource Generation
--[[	if not cm.global_check then
		cm.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(cm.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge3:SetCode(EVENT_CHAIN_SOLVED)
		ge3:SetRange(LOCATION_EXTRA)
		ge3:SetOperation(cm.acop)
		c:RegisterEffect(ge3,0)
	end]]--
--  Corruption Decay
	local dc1=Effect.CreateEffect(c)
	dc1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dc1:SetCode(EVENT_TURN_END)
	dc1:SetOperation(cm.decayop)
	dc1:SetCountLimit(1)
	Duel.RegisterEffect(dc1,0)
--  immunity effect
	local imn1=Effect.CreateEffect(c)
	imn1:SetType(EFFECT_TYPE_SINGLE)
	imn1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	imn1:SetRange(LOCATION_EXTRA)
	imn1:SetCode(EFFECT_IMMUNE_EFFECT)
	imn1:SetCondition(cm.imn1con)
	imn1:SetValue(cm.imn1filter)
	c:RegisterEffect(imn1)
-------------------------
-- CORRUPTION NEGATIVES--
-------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(cm.vgcondition)
	e2:SetTarget(cm.vgtarget)
	e2:SetOperation(cm.vgoperation)
	c:RegisterEffect(e2)

--  Draw replace
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.discon)
	e1:SetTarget(cm.distg)
	e1:SetOperation(cm.disop)
	c:RegisterEffect(e1)

--  Random Target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.rtgcondition)
	e3:SetOperation(cm.rtgoperation)
	c:RegisterEffect(e3)	

--  Cascading Disaster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCondition(cm.retcondition)
	e4:SetTarget(cm.rettg)
	e4:SetOperation(cm.retop)
	c:RegisterEffect(e4)

--  Torn Souls
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetCondition(cm.tscondition)
	e5:SetTarget(cm.tstarget)
	e5:SetOperation(cm.tsactivate)
	c:RegisterEffect(e5)

--  Torment
	local cn1=Effect.CreateEffect(c)
	cn1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	cn1:SetCode(EVENT_CHAINING)
	cn1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	cn1:SetRange(LOCATION_EXTRA)
	cn1:SetOperation(cm.regop)
	c:RegisterEffect(cn1,0)
	local cn2=Effect.CreateEffect(c)
	cn2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	cn2:SetCode(EVENT_CHAIN_SOLVED)
	cn2:SetRange(LOCATION_EXTRA)
	cn2:SetCondition(cm.atkcon)
	cn2:SetOperation(cm.atkop)
	c:RegisterEffect(cn2,0)

--  Decaying Life
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetCondition(cm.dlcon)
	e6:SetOperation(cm.dlop)
	c:RegisterEffect(e6)
	local dl1=Effect.CreateEffect(c)
	dl1:SetType(EFFECT_TYPE_FIELD)
	dl1:SetCode(EFFECT_CHANGE_DAMAGE)
	dl1:SetTargetRange(1,0)
	dl1:SetRange(LOCATION_EXTRA)
	dl1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	dl1:SetCondition(cm.dlcon)
	dl1:SetValue(cm.dlval1)
	c:RegisterEffect(dl1)
end


------------------
--Card immunity --
------------------

function cm.imn1con(e)
	return e:GetHandler():IsFaceup()
end

function cm.imn1efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

------------------
--gamestart init--
------------------

function cm.startcon(e,tp,eg,ep,ev,re,r,rp)
		return (Duel.GetFlagEffect(tp,88866600) < 100)
end

function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	-- Horrific Echos
	if Duel.GetFlagEffect(tp,88866600) == 0 then
		Duel.RegisterFlagEffect(tp,88866600,RESET_DISABLE,0,1)
		Duel.Remove(c,tp,REASON_EFFECT)
		Duel.SendtoExtraP(c,tp,REASON_EFFECT)
	end
	Duel.SetFlagEffectLabel(tp,88866600,150)
	-- Corruption
	if Duel.GetFlagEffect(tp,88866600) == 0 then
		Duel.RegisterFlagEffect(tp,88866601,RESET_DISABLE,0,1)
	end
end

-----------------------
--resource generation--
-----------------------

function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	local dr=Duel.GetFlagEffect(tp,88866602)
	local max=5
	if dr>max then dr=5 end
	local inc= 15-(dr*3)
	local cur= Duel.GetFlagEffectLabel(tp,88866600)
	local min= 0
	if cur<min then dr=0 end	
	local new= cur + inc
	Duel.SetFlagEffectLabel(tp,88866600,new)
	Duel.RegisterFlagEffect(tp,88866602,RESET_PHASE+PHASE_END,0,1)
end

function cm.acop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	if not re:GetHandler():IsCode(m) then
		local dr=Duel.GetFlagEffect(tp,88866603)
		local max=5
		if dr>max then dr=5 end
		local inc= 15-(dr*3)
		local cur= Duel.GetFlagEffectLabel(tp,88866600)
		local min= 0
		if cur<min then dr=0 end	
		local new= cur + inc
		Duel.SetFlagEffectLabel(tp,88866600,new)
		Duel.RegisterFlagEffect(tp,88866603,RESET_PHASE+PHASE_END,0,1)
	end
end

----------------
--Decay effect--
----------------

function cm.decayop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	local cur= Duel.GetFlagEffectLabel(tp,88866601)
	local new= math.floor(cur * 0.67)
	Duel.SetFlagEffectLabel(tp,88866601,new)
end

-------------
--Draw Test--
-------------


function cm.testcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=0
	return echos>=cost
end

function cm.testtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
--  cost
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=0
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=40
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
end

function cm.testop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
	end
end

-----------------------
--Horrific Echo check--
-----------------------

function cm.horrific_echo_check_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

function cm.horrific_echo_check_op(e,tp,eg,ep,ev,re,r,rp)
	local echox=Duel.GetFlagEffectLabel(tp,88866600)
	Duel.AnnounceNumber(tp,echox)
end

--------------------
--Corruption check--
--------------------

function cm.corruption_check_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

function cm.corruption_check_op(e,tp,eg,ep,ev,re,r,rp)
	local corruptionx=Duel.GetFlagEffectLabel(tp,88866601)
	Duel.AnnounceNumber(tp,corruptionx)
end

-----------------------
--End of Init effects--
-----------------------

-----------------------------------
--Start of Pos Corruption effects--
-----------------------------------


-------------------------------
--NEGATIVE CORRUPTION EFFECTS--
-------------------------------

-----------
--Void grasp--
-----------

function cm.vgcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=1
	local check = math.random() * 100
	return corruption>=threshold 
		and ep==tp
		and check <= corruption
end

function cm.vgtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end

function cm.vgoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0,nil)
	local sg=g:RandomSelect(ep,1)
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-----------
--draw rep-
-----------

function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH) 
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=30
	local check = math.random() * 100
	local cap = ((corruption - threshold))
	if cap >= 80 then cap=80 end
	return corruption>=threshold and check <= cap and ex5 and Duel.IsChainDisablable(ev) and ep==tp
end

function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	Duel.NegateEffect(ev)
	Duel.Draw(tp,1,REASON_REPLACE)
end
-----------------
--Random Target--
-----------------

function cm.rtgcondition(e,tp,eg,ep,ev,re,r,rp)
--  if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
--  local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
--  if not g then return false end
--  local tc=g:GetFirst()
--  e:SetLabelObject(tc)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=60
	local tp2 = Duel.GetTurnPlayer()
	return corruption>=threshold and tp2==tp
end
--[[
function cm.rtgilter(c,ct)
	return Duel.CheckChainTarget(ct,c)
end

function cm.rtgtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=ev
	local label=Duel.GetFlagEffectLabel(0,21501505)
	if label then
		if ev==bit.rshift(label,16) then ct=bit.band(label,0xffff) end
	end
	if chkc then return chkc:IsOnField() and cm.rtgfilter(chkc,ct) end
	if chk==0 then return Duel.IsExistingTarget(cm.rtgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabelObject(),ct) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local val=ct+bit.lshift(ev+1,16)
	if label then
		Duel.SetFlagEffectLabel(0,2150150,val)
	else
		Duel.RegisterFlagEffect(0,2150150,RESET_CHAIN,0,1,val)
	end
end

]]--
function cm.rtgoperation(e,tp,eg,ep,ev,re,r,rp)
--  local g=Duel.GetMatchingGroup(cm.rtgilter,tp,0,LOCATION_MZONE,nil)
--  local sg=g:RandomSelect(ep,1)
--  local sg2=sg:GetFirst()
--  Duel.ChangeTargetCard(ev,Group.FromCards(sg2))
--  local g=Duel.GetMatchingGroup(cm.rtgilter,tp,0,LOCATION_MZONE,nil)
--  Duel.ChangeTargetCard(ev,g:RandomSelect(ep,1))
	local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD+LOCATION_HAND,0)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local x = math.floor(corruption/50)
	local sg=g2:Select(tp,x,x,nil)
	Duel.HintSelection(sg)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end


--Cascading Disaster
function cm.retcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=90
	local check = math.random() * 100
	local cap = ((corruption - threshold)) * 0.25
	if cap >= 50 then cap=50 end
	return corruption>=threshold and check <= cap and rp==tp
end

function cm.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
end
function cm.getf(s,loc,g,e,tp)
	if s<0 or s>4 then return end
	local tc=Duel.GetFieldCard(1-tp,loc,s)
	if tc and not tc:IsImmuneToEffect(e) then g:AddCard(tc) end
end
function cm.move(c,co,e)
	if c:IsImmuneToEffect(e) then return end
	local s=c:GetSequence()
	if s==co then
		cm.exile(c,e)
	elseif s>co then
		if Duel.CheckLocation(c:GetControler(),c:GetLocation(),s-1) then
			Duel.MoveSequence(c,s-1)
		else
			cm.exile(c,e)
		end
	elseif s<co then
		if Duel.CheckLocation(c:GetControler(),c:GetLocation(),s+1) then
			Duel.MoveSequence(c,s+1)
		else
			cm.exile(c,e)
		end
	end
end

function cm.exile(c,e)
	if c:IsImmuneToEffect(e) then return end
	Senya.ExileCard(c)
	Duel.SendtoGrave(c,REASON_RULE+REASON_RETURN)
end

function cm.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=1-e:GetHandlerPlayer()
	local co=4
	if c:IsControler(tp) then
		if co==5 then co=3
		elseif co==6 then co=1
		else co=4-co end
	else
		if co==5 then co=1
		elseif co==6 then co=3 end
	end
	for j=5,6 do
		local pc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,j)
		if pc and pc:IsControler(1-tp) then
			cm.exile(pc,e)
		end
	end
	for j=0,1 do
		local pc=Duel.GetFieldCard(1-tp,LOCATION_PZONE,j)
		if pc and pc:IsControler(1-tp) then
			cm.exile(pc,e)
		end
	end
	local pc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if pc and pc:IsControler(1-tp) then
		cm.exile(pc,e)
	end
	for i=0,4 do
		for loc=4,8,4 do
			local g=Group.CreateGroup()
			cm.getf(co+i,loc,g,e,tp)
			cm.getf(co-i,loc,g,e,tp)
			if #g==1 then
				cm.move(g:GetFirst(),co,e)
			elseif #g==2 then
				Duel.Hint(HINT_SELECTMSG,1-tp,m*16+2)
				local tc1=g:Select(1-tp,1,1,nil):GetFirst()
				g:RemoveCard(tc1)
				cm.move(tc1,co,e)
				local tc2=g:GetFirst()
				cm.move(tc2,co,e)
			end
		end
	end
end
--------------
--Torn Souls--
--------------

function cm.tscondition(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local threshold=90
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local check = math.random() * 100
	local cap = ((corruption - threshold))
	if cap >= 50 then cap=50 end
	return corruption>=threshold and check <= cap and rp==tp and re:IsActiveType(TYPE_MONSTER)
end

function cm.tstarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function cm.tsactivate(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local sg=g:Filter(Card.IsCode,nil,re:GetHandler():GetCode())
	local sg2=sg:RandomSelect(ep,1)
	Duel.Remove(sg2,POS_FACEDOWN,REASON_EFFECT)
end


-----------
--Torment--
-----------
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,88866604,RESET_EVENT+RESET_CHAIN,0,1)
end

function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=150
	return corruption>=threshold and Duel.GetFlagEffect(tp,88866604)
end

function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsCode(m) then
	local totalatk=0
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	local dmg = (Duel.GetFlagEffectLabel(tp,88866601) * 2)
	while tc do
		local a1=tc:GetAttack()
		local ATK=Effect.CreateEffect(e:GetHandler())
		ATK:SetType(EFFECT_TYPE_SINGLE)
		ATK:SetCode(EFFECT_UPDATE_ATTACK)
		ATK:SetValue(-dmg)
		ATK:SetReset(RESET_EVENT+RESETS_STANDARD) 
		tc:RegisterEffect(ATK)
		tc=g:GetNext()
	end
	end
end

-----------------
--Decaying Life--
-----------------

function cm.dlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=210
	return corruption>=threshold
end

function cm.dlop(e,tp,eg,ep,ev,re,r,rp)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	Duel.PayLPCost(tp,corruption * 3)
end



function cm.dlval1(e,re,dam,r,rp,rc)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local corperc = corruption/100
	return dam * corperc
end




--[[ Horrific Echos 
	Duel.RegisterFlagEffect(tp,88866600,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866600,0)
	-- Corruption
	Duel.RegisterFlagEffect(tp,88866601,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866601,0)
	-- Diminishing Returns A
	Duel.RegisterFlagEffect(tp,88866602,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866602,0)
	-- Diminishing Returns B
	Duel.RegisterFlagEffect(tp,88866603,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866603,0)
	-- Torment
	Duel.RegisterFlagEffect(tp,88866604,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866604,0)
	-- Burn
	Duel.SetFlagEffectLabel(tp,88866605,0) 
	Duel.SetFlagEffectLabel(tp,88866606,0)
	-- Target
	Duel.SetFlagEffectLabel(tp,88866607,0) 
]]--
