--Catapult Barrel Unit
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,6,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--If this card is Time Leap Summoned: You can target 1 monster your opponent controls; destroy it, and if you do, inflict damage to your opponent equal to half it's original ATK.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --When your opponent activates a card or effect that would Tribute a monster(s) they control or target a monster(s) you control (Quick Effect): You can toss a coin 3 times; negate the activation if 2+ of the results are Heads.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2,id)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
	--Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetLabel(id)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_RELEASE)
		ge2:SetOperation(s.checkop2)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.sumcon(e,c)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return Duel.GetFlagEffect(tp,id)~=0 or Duel.GetFlagEffect(tp,id+1)~=0
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return c:IsLevelBelow(ef-1) and c:IsType(TYPE_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local atk=tc:GetBaseAttack()
        if Duel.Destroy(tc,REASON_EFFECT)~=0 then
            Duel.Damage(1-tp,atk/2,REASON_EFFECT)
        end
    end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
    return ((re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and g and g:IsExists(s.cfilter,1,nil,tp)) or (ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,1-tp)-#tg>0))
        and Duel.IsChainNegatable(ev) and ep~=tp
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local heads=0
    for i=1,3 do
        if Duel.TossCoin(tp,1)==COIN_HEADS then
            heads=heads+1
        end
    end
    if heads>=2 then
        Duel.NegateActivation(ev)
    end
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local p1=false
	local p2=false
	if g and g:IsExists(s.cfilter,1,nil,1) and re:GetHandlerPlayer()==0 then p1=true end
	if g and g:IsExists(s.cfilter,1,nil,0) and re:GetHandlerPlayer()==1 then p2=true end
	if p1 then Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1) end
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) then
			if tc:IsPreviousControler(0) and re:GetHandlerPlayer()==0 then p1=true end
			if tc:IsPreviousControler(1) and re:GetHandlerPlayer()==1 then p2=true end
		end
	end
	if p1 then Duel.RegisterFlagEffect(0,id+1,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(1,id+1,RESET_PHASE+PHASE_END,0,1) end
end
