local m=88886660
local cm=_G["c"..m]

--Example Corruption Card
function cm.initial_effect(c)
---------------------
--MANDATORY EFFECTS--
---------------------
	--makes the card face up--
	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e0:SetOperation(cm.start)
	c:RegisterEffect(e0)

	--Cost per turn--

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1)
	e1:SetOperation(cm.start2)
	c:RegisterEffect(e1)

---------------------
--ACTIVATED EFFECTS--
---------------------
	--Corrupted Greed--

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.draw1con)
	e2:SetTarget(cm.draw1tg)
	e2:SetOperation(cm.draw1op)
	c:RegisterEffect(e2)

	--Surrender to Madness--

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(cm.draw2con)
	e3:SetTarget(cm.draw2tg)
	e3:SetOperation(cm.draw2op)
	c:RegisterEffect(e3)

-----------------
--PASSIVE BOOST--
-----------------
	--Enraged Descent--

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e4:SetCondition(cm.atkcondition)
	e4:SetValue(100)
	c:RegisterEffect(e4)

-----------------
--TURN MODIFIER--
-----------------

	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(m,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetCountLimit(1)
	e5:SetCondition(cm.bdcon)
	e5:SetTarget(cm.bdtg)
	e5:SetOperation(cm.bdop)
	c:RegisterEffect(e5)

--=============--
--GAINED EFFECT--
--=============--

	--Battle Tenacity
	
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(m,3))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetCondition(cm.vrcon)
	e6:SetTarget(cm.vrtg)
	e6:SetOperation(cm.vrop)
	c:RegisterEffect(e6)

end


function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
end
--  This effect moves the card to your extra deck, face-up at the start of the duel, so that its public knowledge. It banishes first only because you can't move from extra deck to extra deck face-up for some bizzare reason.

function cm.start2(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFlagEffect(tp,88866601) < 1) then
		Duel.RegisterFlagEffect(tp,88866601,RESET_DISABLE,0,1)
	end
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
--  Duel.GetFlagEffectLabel(tp,88866601) returns the amount of Corrption you have.
	local inc=5
--  This is the corruption per turn cost. 
	local newc= corruption+inc
--  Works out how much your corruption will be with the increase.
	Duel.SetFlagEffectLabel(tp,88866601,newc)
--  Changes your corruption to that amount.
end


---------------------
--ACTIVATED EFFECTS--
---------------------

-- Corrupted Greed

function cm.draw1con(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
--  Duel.GetFlagEffectLabel(tp,88866600) returns the amount of Horrific Echos you have.
	local cost=40
--  Put your Horrific echo cost here.
	return echos>=cost
--  Checks if you have more echos than the cost (and therefore whether the cost can be paid)
end

function cm.draw1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
--  This remains the same as whatever the target of the normal effect would be.

	--cost--
--  The cost in inside the target function because there's a strange effect when you try to put it in the cost. This is basically meainglesshowever, beause it works perfectly in the target function.
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
--  ammount of echos
	local cost=0
--  same cost as before
	local new= echos-cost
--  calculates what your new number of echos will be after calculation 
	Duel.SetFlagEffectLabel(tp,88866600,new)
--  sets your echos to the new amount
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
--  amount of corruption
	local inc=40
--  amount that your corruption will increase by
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
--  sets your corruption to your previous amount + the amount gained by this effect.

end

function cm.draw1op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
	end
end
-- the OP remains unchanged. For all intents and purposes, imagine that this effect is a normal spell card.


-- Surrender to Madness

function cm.draw2con(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
--  Horrific Echos you have.
	local cost=0
--  Put your Horrific echo cost here.
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
--  Corruption you have.
	local threshold=120
--  Put your Corruption threshold here.
	return corruption>=threshold and echos>=cost 
--  Checks if you have more echos than the cost (and therefore whether the cost can be paid)
--  Checks if you have more echos than the cost (and therefore whether the cost can be paid)
end

function cm.draw2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	--cost--
--  The cost in inside the target function because there's a strange effect when you try to put it in the cost. This is basically meainglesshowever, beause it works perfectly in the target function.
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
--  ammount of echos
	local cost=0
--  same cost as before
	local new= echos-cost
--  calculates what your new number of echos will be after calculation 
	Duel.SetFlagEffectLabel(tp,88866600,new)
--  Since this effect doesn't change your corruption level, no corruption gain is needed.
end

function cm.draw2op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
	end
end
-- the OP remains unchanged. For all intents and purposes, imagine that this effect is a normal spell card.

-----------------
--PASSIVE BOOST--
-----------------

function cm.atkcondition(e,tp,eg,ep,ev,re,r,rp)
--  Sooo, now, this is essentially the same as the previous condition, except this doesn't check for any echos at all. Previous comments work here.
	local tp = e:GetHandlerPlayer()
--  This is to correct going second, since its a passive effect. I'm not sure why this fixed it but it does, just shove it in there.
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=30
	return corruption>=threshold
end

------------------
--Turn Modifier--
------------------

function cm.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
--  Duel.GetFlagEffectLabel(tp,88866600) returns the amount of Horrific Echos you have.
	local cost=40
--  Put your Horrific echo cost here.
	return echos>=cost
--  Checks if you have more echos than the cost (and therefore whether the cost can be paid)
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
-- This target is PURELY a cost, not any kind of targetting effect. For this reason it still has the if chk==0 then return true end part in it. 

function cm.bdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE + PHASE_END)
	--remember this line, its really important--
	e1:SetValue(100)
	Duel.RegisterEffect(e1,tp)
end

--  This part doesn't interact with corruption at all. Nearly any operation from a spell/trap which affects the turn can be put here with no issue.




--==============--
--Gained Effects--
--==============--

--Battle Tenacity

function cm.vrcon(e,tp,eg,ep,ev,re,r,rp)
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	return echos>=cost
end
-- same condition as Corrupted greed essentially, just with cost tweaked.

function cm.vrfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end
--  Filter just for any monster that can be targetted.

function cm.vrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.vrfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(cm.vrfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINSTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.vrfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
--  Simple target for any targettable monster you control.
--  cost
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=20
	local new= echos-cost
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=10
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
--  Same cost as Corrupted Greed too really, just tweak the cost and the increase in corruption.
end

function cm.vrop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,3))
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	--remember this line, its really important--
	tc:RegisterEffect(e1,true)
end
--  Registers the effect on the monster