--Gardrenial Groundskeeper
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,ref.matfilter,2,4,true)
	--Material Check 
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(ref.valchk)
	c:RegisterEffect(e0)
	--OnSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCondition(ref.fuscon)
	e1:SetOperation(ref.fusop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--Foolish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(ref.fuscost)
	e2:SetTarget(ref.grtg)
	e2:SetOperation(ref.grop)
	c:RegisterEffect(e2)
	--Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id+1)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(ref.fuscost)
	e3:SetTarget(ref.destg)
	e3:SetOperation(ref.desop)
	c:RegisterEffect(e3)
	--Revive
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(aux.exccon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(ref.sstg)
	e4:SetOperation(ref.ssop)
	c:RegisterEffect(e4)
end
ref.matvals={}
function ref.matfilter(c) return c:IsRace(RACE_PLANT+RACE_INSECT) end
function ref.valchk(e,c)
	local g=c:GetMaterial()
	local rc={}
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		table.insert(ref.matvals,tc:GetRace())
	end
end
--Activate
function ref.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFlagEffect(tp,id)==0
end
function ref.fusop(e,tp,eg,ep,ev,re,r,rp)
	for _, value in ipairs(ref.matvals) do
		if bit.band(value,RACE_PLANT)==RACE_PLANT then Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,ep,ev) end
		if bit.band(value,RACE_INSECT)==RACE_INSECT then Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id+1,re,r,rp,ep,ev) end
	end
	ref.matvals={}
end
function ref.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,1,1,1)
end
--Foolish
function ref.grfilter(c) return c:IsRace(RACE_INSECT) and c:IsAbleToGrave() end
function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e:GetHandler():RegisterEffect(e1)
	end
end
--Destroy
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function ref.desop(e,tp,eg,e,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget()
	if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_PLANT) then
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	else Duel.Destroy(g,REASON_EFFECT) end
end

--Revive
function ref.ssfilter(c,e,tp)
	return c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler(),e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
