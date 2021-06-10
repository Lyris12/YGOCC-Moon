--Change Blastrize
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_BIGBANG)
end
function cid.cfilter(c)
	return c:IsSetCard(0x37e) and c:IsLevelBelow(4) and c:IsDestructable() and Duel.GetMZoneCount(tp,c)>0
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.Destroy(g,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_BIGBANG) and c:IsLocation(LOCATION_EXTRA)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x37e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end