--created by Walrus, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	c:EnableReviveLimit()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetCondition(aux.PandActCheck)
	e6:SetCost(s.cost)
	e6:SetTarget(s.target)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1,id)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetCondition(function(e) return aux.PandActCheck(e) and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 end)
	e7:SetCost(s.spcost)
	e7:SetTarget(s.sptg)
	e7:SetOperation(s.spop)
	c:RegisterEffect(e7)
	aux.EnablePandemoniumAttribute(c,e6,e7,true,TYPE_RITUAL+TYPE_EFFECT,aux.TRUE,s.actcost)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id+100)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
	e1:SetTarget(s.rgtg)
	e1:SetOperation(s.rgop)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.rev)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCondition(function(e) return Duel.GetAttackTarget() and e:GetHandler():IsStatus(STATUS_OPPO_BATTLE) end)
	e2:SetTarget(s.rdtg)
	e2:SetOperation(s.rdop)
	c:RegisterEffect(e2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_TOEXTRA)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local tc=e:GetHandler() return re and re:GetHandler():IsSetCard(0xc97) and re:GetHandler()~=tc and tc:IsReason(REASON_EFFECT) end)
	e5:SetTarget(s.tg)
	e5:SetOperation(s.op)
	c:RegisterEffect(e5)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return sumtype&SUMMON_TYPE_PANDEMONIUM==SUMMON_TYPE_PANDEMONIUM
end
function s.filter(c,sp)
	return c:GetSummonPlayer()==sp and c:GetSummonLocation()==LOCATION_EXTRA
end
function s.rfilter(c)
	return c:IsSetCard(0xc97) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Remove(Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetParam(500)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,1000,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsSetCard(0x3c97) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsDestructable()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,math.min(ft,2),nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.cfilter(c)
	return c:IsSetCard(0xac97) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_COST)
end
function s.rgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_GRAVE)
end
function s.rgfilter(c)
	return c:IsSetCard(0xc97) and c:IsAbleToRemove()
end
function s.rgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(s.rgfilter,tp,LOCATION_GRAVE,0,nil):SelectSubGroup(tp,aux.dncheck,false,3,3)
	if g then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
function s.repcfilter(c,e,val)
	return c:IsAttackAbove(val) and not c:IsImmuneToEffect(e)
end
function s.rev(e,re,dam,r,rp,rc)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSummonType),tp,0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	local tg=g:Filter(s.repcfilter,nil,e,dam//2)
	local rec=rc
	if not rec and re then rec=re:GetHandler() end
	local val=dam
	Duel.DisableActionCheck(true)
	if r&REASON_EFFECT>0 and #g>0 and #tg>0 then
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-dam//2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		val=0
	end
	Duel.DisableActionCheck(false)
	return val
end
function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,PLAYER_ALL,LOCATION_DECK)
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck()
	Duel.Remove(Duel.GetDecktopGroup(tp,3)+Duel.GetDecktopGroup(1-tp,3),POS_FACEUP,REASON_EFFECT)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsForbidden() end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsForbidden() or not c:IsRelateToEffect(e) then return end
	local b=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(c,nil,c:GetLocation(),c:GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp)
	if b and Duel.SelectOption(tp,1159,1105)==0 then
		aux.PandSSet(c,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
	else
		Duel.SelectOption(tp,1105)
		aux.PandEnableFUInED(c,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
	end
end
