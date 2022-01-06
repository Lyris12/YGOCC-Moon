--Naval Gears - Prinz Eugen
local cid,id=GetID()
function cid.initial_effect(c)
    --link summon
    aux.AddLinkProcedure(c,cid.lfilter,3,99)
    c:EnableReviveLimit()
	--Extra Attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30270176,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(cid.atkcon)
	e1:SetCost(cid.atkcost)
	e1:SetTarget(cid.atktg)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
		--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.atkcon2)
	e2:SetValue(cid.atkval)
	c:RegisterEffect(e2)
	--send 2 spell/trap to grave; move cards to back row
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4066,10))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(cid.descost1)
--	e4:SetTarget(cid.destarget)
	e4:SetOperation(cid.desop)
	c:RegisterEffect(e4)
		if not cid.global_check then
		cid.global_check=true
		cid[0]=0
		cid[1]=0
		end
end
function cid.lfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE)
end
--atk up
function cid.atkcon2(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil
end
function cid.atkval(e,c)
	return Duel.GetAttackTarget():GetAttack()/2
end
--send 2 spell/trap to grave; move cards to back row
function cid.desfilter1(c)
	return  c:IsFaceup()  and c:IsAbleToGraveAsCost()
end
function cid.descost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.desfilter1,tp,LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,cid.desfilter1,tp,LOCATION_SZONE,0,1,2,nil)
	e:SetLabel(#g)
	Duel.SendtoGrave(g,nil,0,REASON_COST)
end
function cid.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
if ct>0 and c:IsRelateToEffect(e) then
local g=Duel.SelectMatchingCard(tp,aux.FilterBoolFunction(aux.NOT(Card.IsImmuneToEffect),e),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,ct,nil)
	local tc=g:GetFirst()
	if not tc then return end
	while tc do
if g:GetCount()>0 then

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+0x1fc0000)
    e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
    tc:RegisterEffect(e1)
    if tc:IsControler(tp) then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
		tc=g:GetNext()
    else Duel.MoveToField(tc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
	tc=g:GetNext()
    end
end
end
end
end
--Extra Attack
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
end
function cid.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsDirectAttacked() end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle()  end
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToBattle() then return end
    if e:GetLabelObject()==nil then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
        c:RegisterEffect(e1)
        e:SetLabelObject(e1)
    else
        e:GetLabelObject():SetValue(e:GetLabelObject():GetValue()+1)
    end
end 