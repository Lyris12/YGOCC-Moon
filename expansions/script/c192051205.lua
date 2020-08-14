--coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():GetSummonLocation()==LOCATION_GRAVE end)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	if not cid.global_check then
		cid.global_check=true
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		ge2:SetOperation(cid.archchk)
		Duel.RegisterEffect(ge2,0)
	end
end
function cid.archchk(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(0,id+21)==0 then 
		Duel.CreateToken(tp,id+21)
		Duel.CreateToken(1-tp,id+21)
		Duel.RegisterFlagEffect(0,id+21,0,0,0)
	end
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x617) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
end
function cid.filter(c,e,tp,lv)
	return c:IsSetCard(0x617) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and (lv==nil) or (c:GetLevel()==lv)
end
function cid.ritfilter(c)
	return c:IsCode(id+21) and not c:IsStatus(STATUS_DISABLED)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(cid.ritfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		sg=Duel.GetMatchingGroup(cid.ritfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		if #sg<=0 then return end
		if #sg>1 then sg=sg:Select(tp,1,1,nil) end
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		sg:GetFirst():CancelToGrave(false)
		_G["c"..tostring(id+21)].ope(e,tp,Group.FromCards(c,tc))
	end
end
