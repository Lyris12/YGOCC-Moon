--created by NeverThisAgain, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.check(c,rc,g)
	return g:IsContains(c) and c:IsCanBeRitualMaterial(rc)
end
function s.alvcheck(c,rc)
	local raw_level=c:GetRitualLevel(rc)
	local lv1=raw_level&0xffff
	local lv2=raw_level>>16
	if lv2>0 then
		return math.min(lv1,lv2)
	else
		return lv1
	end
end
function s.acheck(c,lv)
	return  function(g,ec)
				if ec then
					return g:GetSum(s.alvcheck,c)-s.alvcheck(ec,c)<=lv
				else
					return true
				end
			end
end
function s.filter(c,e,tp,m1,m2)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x50b) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	if m2 and m2:IsExists(s.check,1,c,c,mg) then return true end
	local lv=c:GetLevel()
	aux.GCheckAdditional=s.acheck(c,lv)
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv,tp,c,lv,"Greater")
	aux.GCheckAdditional=nil
	return res
end
function s.mfilter(c)
	return c:GetLevel()>0 and c:IsFaceup() and c:IsType(TYPE_FUSION) and c:GetSummonLocation()==LOCATION_EXTRA
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local exg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,exg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local exg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,exg)
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		local mat=nil
		if exg and exg:IsExists(s.check,1,tc,tc,mg) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			mat=exg:FilterSelect(tp,s.check,1,1,tc,tc,mg)
		else
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local lv=tc:GetLevel()
			aux.GCheckAdditional=s.acheck(tc,lv)
			mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,tc,lv,"Greater")
			aux.GCheckAdditional=nil
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
