-- Corruption Effects --
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
--	c:RegisterEffect(e1)]]--
--  Horrifc Echo Check
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(m,1))
	e2a:SetCategory(CATEGORY_DAMAGE)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetRange(LOCATION_EXTRA)
	e2a:SetTarget(cm.horrific_echo_check_tg)
	e2a:SetOperation(cm.horrific_echo_check_op)
	c:RegisterEffect(e2a)
--  Corruption Check
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(m,2))
	e2b:SetCategory(CATEGORY_DAMAGE)
	e2b:SetType(EFFECT_TYPE_IGNITION)
	e2b:SetRange(LOCATION_EXTRA)
	e2b:SetTarget(cm.corruption_check_tg)
	e2b:SetOperation(cm.corruption_check_op)
	c:RegisterEffect(e2b)
--  Resource Generation
	if not cm.global_check then
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
	end
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
--  Grasping Tendrils
	local grtd1=Effect.CreateEffect(c)
	grtd1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	grtd1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	grtd1:SetCode(EVENT_DAMAGE)
	grtd1:SetRange(LOCATION_EXTRA)
	grtd1:SetCondition(cm.grtdcon)
	grtd1:SetTarget(cm.grtdtg)
	grtd1:SetOperation(cm.grtdop)
	c:RegisterEffect(grtd1)

--  Burning Eye

	local bney1=Effect.CreateEffect(c)
	bney1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	bney1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	bney1:SetCode(EVENT_CHAIN_SOLVING)
	bney1:SetRange(LOCATION_EXTRA)
	bney1:SetCondition(cm.bneycon)
	bney1:SetTarget(cm.bneytg)
	bney1:SetOperation(cm.bneyop)
	c:RegisterEffect(bney1)

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

--  Visions of Madness
	local vom1=Effect.CreateEffect(c)
	vom1:SetType(EFFECT_TYPE_FIELD)
	vom1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	vom1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	vom1:SetRange(LOCATION_EXTRA)
	vom1:SetTargetRange(0xff,0xfe)
	vom1:SetCondition(cm.vom1condition)
	vom1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(vom1)
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
		return (Duel.GetFlagEffect(tp,88866600) < 1)
end

function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	-- Horrific Echos
	Duel.RegisterFlagEffect(tp,88866600,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866600,0)
	-- Corruption
	Duel.RegisterFlagEffect(tp,88866601,RESET_DISABLE,0,1)
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
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
	local new= math.floor(cur * 0.75)
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


------------------------------
--NEGATIVE CORRUPTION EFFECT--
------------------------------
--------------------
--Grasping Tendril--
--------------------
--[[1+ :Taking damage has a chance to spawn a "Grasping Tendril" token to your opponents field with the following effects, based on the amount of corruption you have. (DARK/Fiend/Level 1/ATK???/DEF???) (This Token's ATK and DEF become equal to your corruption x 50.)
1) 0+ (Quick Effect) You can banish this card.
2) 25+ Once per turn, this card cannot be destroyed.
3) 50+ Once per turn, you can  target 1 card your opponent controls; destroy that target.
4) 75+ If this card attacks, your opponent cannot activate cards or effects during the Battle Phase.
5) 100+ This card is unaffected by card effects.
]]--


function cm.grtdcon(e,tp,eg,ep,ev,re,r,rp)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=0
	local rcheck = math.ceil(math.random() * 200)
	return corruption>=threshold and rcheck < corruption and ep==tp
end

function cm.grtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,1)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0,0x4011,corruption * 40,corruption * 40,1,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end

function cm.grtdop(e,tp,eg,ep,ev,re,r,rp)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	if corruption>0 then
		local c=e:GetHandler()
			local atk=corruption * 40
			local def=corruption * 40
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0,0x4011,corruption * 40,corruption * 40,1,RACE_FIEND,ATTRIBUTE_DARK) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,8886661)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE)
			e2:SetValue(def)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetCategory(CATEGORY_REMOVE)
			e3:SetType(EFFECT_TYPE_IGNITION)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCountLimit(1)
			e3:SetTarget(cm.grtdoptarget)
			e3:SetOperation(cm.grtdopoperation)
			token:RegisterEffect(e3)
			if corruption >= 25 then
				local e3a=Effect.CreateEffect(c)
				e3a:SetType(EFFECT_TYPE_SINGLE)
				e3a:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
				e3a:SetRange(LOCATION_MZONE)
				e3a:SetValue(1)
				token:RegisterEffect(e3a)
			end
			if corruption >= 50 then
				local e4=Effect.CreateEffect(c)
				e4:SetDescription(aux.Stringid(48905153,1))
				e4:SetCategory(CATEGORY_DESTROY)
				e4:SetType(EFFECT_TYPE_IGNITION)
				e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
				e4:SetRange(LOCATION_MZONE)
				e4:SetCountLimit(1)
				e4:SetTarget(cm.grtdopdestg)
				e4:SetOperation(cm.grtdopdesop)
				token:RegisterEffect(e4)
			end
			if corruption >= 75 then
				local e5=Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_FIELD)
				e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e5:SetCode(EFFECT_CANNOT_ACTIVATE)
				e5:SetRange(LOCATION_MZONE)
				e5:SetTargetRange(0,1)
				e5:SetValue(1)
				e5:SetCondition(cm.grtdopactcon)
				token:RegisterEffect(e5)
			end
			if corruption >= 999 then
				local e6=Effect.CreateEffect(c)
				e6:SetType(EFFECT_TYPE_SINGLE)
				e6:SetCode(EFFECT_IMMUNE_EFFECT)
				e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e6:SetRange(LOCATION_MZONE)
				e6:SetValue(cm.grtdopimfilter)
				c:RegisterEffect(e6)
			end
			Duel.SpecialSummon(token,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end

function cm.grtdoptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function cm.grtdopoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,tc:GetPosition(),REASON_EFFECT) 
	end
end

function cm.grtdopimfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function cm.grtdopactcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end

function cm.grtdopdescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function cm.grtdopdestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

---------------------
--Burning Eye Token--
---------------------

function cm.bneycon(e,tp,eg,ep,ev,re,r,rp)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=30
	local rcheck = math.ceil(math.random() * 200)
	return corruption>=threshold and rcheck < (corruption + 10) and ep==tp
end

function cm.bneytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,1)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0,0x4011,corruption * 50,corruption * 50,1,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end

function cm.bneyop(e,tp,eg,ep,ev,re,r,rp)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	if corruption>0 then
		local c=e:GetHandler()
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0,0x4011,1500,1500,3,RACE_FIEND,ATTRIBUTE_DARK) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,8886662)
			local e3=Effect.CreateEffect(c)
			e3:SetCategory(CATEGORY_REMOVE)
			e3:SetType(EFFECT_TYPE_IGNITION)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCountLimit(1)
			e3:SetTarget(cm.bneyoptarget)
			e3:SetOperation(cm.bneyopoperation)
			token:RegisterEffect(e3)
			if corruption >= 30 then
				local e3a=Effect.CreateEffect(c)
				token:RegisterEffect(e3a)
				e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e3a:SetCode(EVENT_TO_HAND)
				e3a:SetProperty(EFFECT_FLAG_DELAY)
				e3a:SetRange(LOCATION_MZONE)
				e3a:SetCondition(cm.bneyopdamcon1)
				e3a:SetOperation(cm.bneyopdamop1)
				token:RegisterEffect(e3a)
				local e3b=Effect.CreateEffect(c)
				e3b:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
				e3b:SetCode(EVENT_TO_HAND)
				e3b:SetRange(LOCATION_MZONE)
				e3b:SetCondition(cm.bneyopregcon)
				e3b:SetOperation(cm.bneyopregop)
				token:RegisterEffect(e3b)
				local e3c=Effect.CreateEffect(c)
				e3c:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
				e3c:SetCode(EVENT_CHAIN_SOLVED)
				e3c:SetRange(LOCATION_MZONE)
				e3c:SetCondition(cm.bneyopdamcon2)
				e3c:SetOperation(cm.bneyopdamop2)
				token:RegisterEffect(e3c)
				if not c.global_check then
					cm.global_check=true
					local bneyopge1=Effect.CreateEffect(c)
					bneyopge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					bneyopge1:SetCode(EVENT_CHAIN_SOLVING)
					bneyopge1:SetOperation(cm.bneyopcount)
					Duel.RegisterEffect(bneyopge1,0)
					local bneyopge2=Effect.CreateEffect(c)
					bneyopge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					bneyopge2:SetCode(EVENT_CHAIN_SOLVED)
					bneyopge2:SetOperation(cm.bneyopreset)
					Duel.RegisterEffect(bneyopge2,0)
				end
			end
			if corruption >= 50 then
				local e4a=Effect.CreateEffect(c)
				e4a:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
				e4a:SetRange(LOCATION_MZONE)
				e4a:SetProperty(EFFECT_FLAG_DELAY)
				e4a:SetCode(EVENT_SPSUMMON_SUCCESS)
				e4a:SetCondition(cm.bgeye4drcon1)
				e4a:SetOperation(cm.bgeye4drop1)
				token:RegisterEffect(e4a)
				--sp_summon effect
				local e4b=Effect.CreateEffect(c)
				e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e4b:SetCode(EVENT_SPSUMMON_SUCCESS)
				e4b:SetRange(LOCATION_MZONE)
				e4b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e4b:SetCondition(cm.bgeye4regcon)
				e4b:SetOperation(cm.bgeye4regop)
				token:RegisterEffect(e4b)
				local e4c=Effect.CreateEffect(c)
				e4c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e4c:SetCode(EVENT_CHAIN_SOLVED)
				e4c:SetRange(LOCATION_MZONE)
				e4c:SetCondition(cm.bgeye4drcon2)
				e4c:SetOperation(cm.bgeye4drop2)
				token:RegisterEffect(e4c)
			end
			if corruption >= 70 then
				local e5a=Effect.CreateEffect(c)
				e5a:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
				e5a:SetCode(EVENT_CHAIN_SOLVED)
				e5a:SetRange(LOCATION_MZONE)
				e5a:SetOperation(cm.bgeye5aacop)
				token:RegisterEffect(e5a)
			end
			if corruption >= 100 then
				local e6=Effect.CreateEffect(c)
				e6:SetType(EFFECT_TYPE_FIELD)
				e6:SetCode(EFFECT_CHANGE_DAMAGE)
				e6:SetRange(LOCATION_MZONE)
				e6:SetTargetRange(0,1)
				e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e6:SetValue(cm.bgeye6hdval)
				token:RegisterEffect(e6)
			end
			Duel.SpecialSummon(token,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end

--E6--
function cm.bgeye6hdval(e,re,dam,r,rp,rc)
	return dam+400
end

--E5--

function cm.bgeye5aacop(e,tp,eg,ep,ev,re,r,rp)
	if (ep~=tp) then
		Duel.Damage(1-tp,300,REASON_EFFECT)
	end
end

--E4--
function cm.bgeye4filter(c,sp)
	return c:GetSummonPlayer()==sp
end
function cm.bgeye4drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.bgeye4filter,1,nil,1-tp)
		and (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end

function cm.bgeye4drop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,300,REASON_EFFECT)
end

function cm.bgeye4regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.bgeye4filter,1,nil,1-tp)
		and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end

function cm.bgeye4regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,88866606,RESET_CHAIN,0,1)
end

function cm.bgeye4drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,88866606)>0
end
function cm.bgeye4drop2(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFlagEffect(tp,88866606)
	Duel.ResetFlagEffect(tp,88866606)
	Duel.Damage(1-tp,300 * n,REASON_EFFECT)
end

--E3--


function cm.bneyoptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function cm.bneyopoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,tc:GetPosition(),REASON_EFFECT) 
	end
end

function cm.bneyopcount(e,tp,eg,ep,ev,re,r,rp)
	cm.bneyopchain_solving=true
end
function cm.bneyopreset(e,tp,eg,ep,ev,re,r,rp)
	cm.bneyopchain_solving=false
end

function cm.bneyopdamcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and not cm.chain_solving
end

function cm.bneyopdamop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,8886662)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
end

function cm.bneyopregcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and cm.bneyopchain_solving
end

function cm.bneyopregop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(88866605,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,ct)
end

function cm.bneyopdamcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(88866605)>0
end

function cm.bneyopdamop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,8886662)
	local labels={e:GetHandler():GetFlagEffectLabel(88866605)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(88866605)
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
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
	local threshold=100
	return corruption>=threshold and Duel.GetFlagEffect(tp,88866604)
end

function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsCode(m) then
	local totalatk=0
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	local dmg = (Duel.GetFlagEffectLabel(tp,88866601) * 5)
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
	Duel.Damage(tp,dmg,REASON_EFFECT)
	end
end

----------------------
--VISIONS OF MADNESS--
----------------------

function cm.vom1condition(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=70
	local rcheck = math.ceil(math.random() * 200)
	return corruption>=threshold and (rcheck) < (corruption -20)
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
