--Radiant Markshall
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddXyzProcedureLevelFree(c,cid.mfilter,cid.xyzcheck,2,99)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_PZONE)
	p1:SetCountLimit(1,id)
	p1:SetTarget(cid.dptg)
	p1:SetOperation(cid.dpop)
	c:RegisterEffect(p1)
	--name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(63553469)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(cid.atkcon)
	e2:SetTarget(cid.atktg)
	e2:SetValue(-3000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e3:SetTarget(cid.atktg2)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(cid.spcon)
	e4:SetCost(cid.spcost)
	e4:SetTarget(cid.sptg)
	e4:SetOperation(cid.spop)
	c:RegisterEffect(e4)
end
function cid.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,7)
end
function cid.xyzcheck(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x7a4)
end
--ACTIVATE
function cid.dpfilter(c,tp,typ,cc)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsType(typ)
		and ((typ==TYPE_PANDEMONIUM and Duel.GetMZoneCount(tp,Group.FromCards(c,cc))>0) or Duel.IsExistingMatchingCard(cid.dpfilter,tp,LOCATION_MZONE,0,1,c,tp,TYPE_PANDEMONIUM,c))
end
--------
function cid.dptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dpfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp,TYPE_PENDULUM,nil)
		 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.dpop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,cid.dpfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,TYPE_PENDULUM,nil)
	local g2=Duel.SelectMatchingCard(tp,cid.dpfilter,tp,LOCATION_MZONE,0,1,1,g1,tp,TYPE_PANDEMONIUM,g1:GetFirst())
	g2:Merge(g1)
	if g1:GetCount()==2 then
		Duel.HintSelection(g1)
		if Duel.Destroy(g1,REASON_EFFECT)~=0 then
			if not e:GetHandler():IsRelateToEffect(e) or not e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) then return end
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--ATK
function cid.atkcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
function cid.atktg(e,c)
	return not c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
end
function cid.atktg2(e,c)
	return c~=e:GetHandler()
end
--SPECIAL SUMMON
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end