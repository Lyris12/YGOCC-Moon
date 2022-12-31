--Salvazione Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,34843)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local en=Duel.GetEngagedCard(tp)
		if not en then return false end
		for i=1,3 do
			if en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:NotBanishedOrFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	if not en then return end
	local nums={}
	for i=1,3 do
		if en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then
			table.insert(nums,i)
		end
	end
	if #nums==0 then return end
	local n=Duel.AnnounceNumber(tp,table.unpack(nums))
	local _,diff=en:UpdateEnergy(n,tp,REASON_EFFECT,true,e:GetHandler())
	if diff==n and Duel.IsExistingMatchingCard(aux.Faceup(Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,34843) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GB,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GB,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end