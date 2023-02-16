--Gardrenial Guardian Spirit
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,2,ref.lchk)
	--Race Gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(RACE_PLANT+RACE_INSECT)
	c:RegisterEffect(e1)
	--Fusion
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(ref.fustg)
	e2:SetOperation(ref.fusop)
	c:RegisterEffect(e2)
end
function ref.lchk(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_PLANT+RACE_INSECT,lc,sumtype,tp)
end

function ref.fusfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:CheckFusionMaterial(Duel.GetFusionMaterial(tp),nil,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function ref.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function ref.fusop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fg=Duel.SelectMatchingCard(tp,ref.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
	if #fg>0 then
		local fc=fg:GetFirst()
		local mg=Duel.SelectFusionMaterial(tp,fc,Duel.GetFusionMaterial(tp),c,tp)
		fc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		if Gardrenial.Is(fc) then Duel.Draw(tp,1,REASON_EFFECT) end
	end
end
