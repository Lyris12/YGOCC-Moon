--created by Walrus, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e0:SetTargetRange(1,1)
	e0:SetTarget(cid.splimit)
	c:RegisterEffect(e0)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetCondition(aux.PandActCheck)
	e4:SetCost(cid.cost)
	e4:SetTarget(cid.rmtg)
	e4:SetOperation(cid.rmop)
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(cid.settg)
	e1:SetOperation(cid.setop)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1,e4)
	aux.CannotBeEDMaterial(c,nil,LOCATION_MZONE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCondition(cid.spcon)
	e3:SetOperation(cid.spop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_TOEXTRA)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id) end)
	e5:SetTarget(cid.tg)
	e5:SetOperation(cid.op)
	c:RegisterEffect(e5)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumtype,SUMMON_TYPE_PANDEMONIUM)==SUMMON_TYPE_PANDEMONIUM
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,1000,REASON_COST)
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==3 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,0,0)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.DisableShuffleCheck()
	Duel.Remove(Duel.GetDecktopGroup(tp,3),POS_FACEUP,REASON_EFFECT)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x3c97) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)>0 then Duel.Damage(tp,1000,REASON_EFFECT) end
end
function cid.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3c97) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function cid.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp),POS_FACEUP,REASON_COST)
end
function cid.rfilter(c)
	return c:IsSetCard(0x3c97) and (c:IsAbleToRemove() or aux.nzatk(c) or aux.nzdef(c))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.rfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,cid.rfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not tc then return end
	local b1,b2=tc:IsAbleToRemove(),aux.nzatk(tc) or aux.nzdef(tc)
	if b2 and (not b1 or Duel.SelectOption(tp,1123,1102)==0) then
		Duel.Recover(tp,math.max(tc:GetAttack(),tc:GetDefense()),REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	else Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsForbidden() end
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsForbidden() then return end
	local b=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(c,nil,c:GetLocation(),c:GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp)
	if b and Duel.SelectOption(tp,1159,1105)==0 then
		aux.PandSSet(c,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
	else
		Duel.SelectOption(tp,1105)
		aux.PandEnableFUInED(c,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
	end
end
