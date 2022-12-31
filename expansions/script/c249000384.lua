--Elven Mage Paladin - Sapphira
function c249000384.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,2490003841)
	e1:SetCondition(c249000384.spcon)
	e1:SetOperation(c249000384.spop)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12510878,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c249000384.condition)
	e2:SetTarget(c249000384.target)
	e2:SetOperation(c249000384.operation)
	c:RegisterEffect(e2)
	--copy spell
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2490003842)
	e3:SetCost(c249000384.cost)
	e3:SetTarget(c249000384.target2)
	e3:SetOperation(c249000384.operation2)
	c:RegisterEffect(e3)
end
function c249000384.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),Card.IsSetCard,1,nil,0x1B7)
end
function c249000384.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(c:GetControler(),Card.IsSetCard,1,1,nil,0x1B7)
	Duel.Release(g,REASON_COST)
end
function c249000384.rmfilter(c)
	return c:IsSetCard(0x1B7) and c:IsAbleToRemoveAsCost() and ((not c:IsLocation(LOCATION_EXTRA)) or (c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)))
end
function c249000384.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c249000384.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249000384.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c249000384.rmfilter(c)
	return c:IsSetCard(0x1B7) and c:IsAbleToRemoveAsCost() and ((not c:IsLocation(LOCATION_EXTRA)) or (c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)))
end
function c249000384.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000384.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	local sg=Duel.SelectMatchingCard(tp,c249000384.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function c249000384.copyfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:GetType()==0x2 or not c:GetType()==0x10002 then return end
	local te
	if c:GetOriginalCode()==57734012 then
		te=c:CheckActivateEffect(true,true,false)
	else
		te=c:CheckActivateEffect(true,false,false)
	end
	if not te or not te:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then return end
	local co=te:GetCost()
	if c:GetOriginalCode()==57734012 then co=nil end
	local tg=te:GetTarget()
	return (not co or co(e,tp,eg,ep,ev,re,r,rp,0)) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) and (not c:IsLocation(LOCATION_GRAVE) or c:IsAbleToRemove()) 
end
function c249000384.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000384.copyfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c249000384.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,c249000384.copyfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_GRAVE) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) else Duel.SendtoGrave(tc,REASON_EFFECT) end
	local te=tc:CheckActivateEffect(true,true,false)
	local co=te:GetCost()
	local tg=te:GetTarget()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(te)
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then
		if tc:IsSetCard(0x95) then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		else
			tg(te,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g and g:GetCount()>0 then
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
	end
	if op then
		if tc:IsSetCard(0x95) then
			op(e,tp,eg,ep,ev,re,r,rp)
		else
			op(te,tp,eg,ep,ev,re,r,rp)
		end
	end
	tc:ReleaseEffectRelation(te)
	if g and g:GetCount()>0 then
		local etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
		end
	end
end
