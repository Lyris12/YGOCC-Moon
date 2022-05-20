--created by Walrus, coded by Lyris
--Voidictator Demon - Lichguard of Corvus
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,5,function(e,tc) return Duel.GetFieldGroupCount(tc:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)>=10 end,s.tlfilter)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_TIMELEAP_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetTargetRange(LOCATION_HAND,0)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3c97))
	c:RegisterEffect(e0)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetTarget(s.disable)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+100)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCountLimit(1,id+200)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCondition(s.con)
	e5:SetCost(s.cost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_REMOVE)
	e4:SetCountLimit(1,id)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
function s.tlfilter(c,e,mg)
	return c:IsSetCard(0x3c97) and c:GetLevel()==e:GetHandler():GetFuture()-1
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xc97)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3c97)
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and c:IsType(TYPE_TIMELEAP)
end
function s.cfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	local ex1,tg1,tc1=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local ex2,tg2,tc2=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
	local ex3,tg3,tc3=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex4,tg4,tc4=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	local ex5,tg5,tc5=Duel.GetOperationInfo(ev,CATEGORY_TOEXTRA)
	local ex6,tg6,tc6=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	local ex7,tg7,tc7=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	local ct1=ex1 and tg1~=nil and tc1+tg1:FilterCount(s.cfilter,nil,tp)-#tg1 or 0
	local ct2=ex2 and tg2~=nil and tc2+tg2:FilterCount(s.cfilter,nil,tp)-#tg2 or 0
	local ct3=ex3 and tg3~=nil and tc3+tg3:FilterCount(s.cfilter,nil,tp)-#tg3 or 0
	local ct4=ex4 and tg4~=nil and tc4+tg4:FilterCount(s.cfilter,nil,tp)-#tg4 or 0
	local ct5=ex5 and tg5~=nil and tc5+tg5:FilterCount(s.cfilter,nil,tp)-#tg5 or 0
	local ct6=ex6 and tg6~=nil and tc6+tg6:FilterCount(s.cfilter,nil,tp)-#tg6 or 0
	local ct7=ex7 and tg7~=nil and tc7+tg7:FilterCount(s.cfilter,nil,tp)-#tg7 or 0
	local ct=0
	if ct1>0 then ct=ct+ct1 end
	if ct2>0 then ct=ct+ct2 end
	if ct3>0 then ct=ct+ct3 end
	if ct4>0 then ct=ct+ct4 end
	if ct5>0 then ct=ct+ct5 end
	if ct6>0 then ct=ct+ct6 end
	if ct7>0 then ct=ct+ct7 end
	e:SetLabel(ct)
	return ct>0
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,500*e:GetLabel(),REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return not re:GetHandler():IsDisabled() end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP) and r&REASON_EFFECT+REASON_BATTLE~=0 and (r&REASON_BATTLE~=0 or rp~=tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,1000,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsCode(id-19) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0xac97) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(function(e,c) return Duel.GetMatchingGroupCount(s.afilter,c:GetControler(),LOCATION_REMOVED,0,nil)*100 end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,1000,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
	end
end
