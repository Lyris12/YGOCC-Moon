--created by Seth, coded by Lyris
--Mextropolis City
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xee5))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_LINK)
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.xfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xee5)
end
function s.spcon(e,tp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xee5) and (c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_MONSTER))
		and c:IsAbleToGraveAsCost()
end
function s.gchk(g,e,tp)
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function s.sfilter(c,e,tp,g)
	return s.filter(c) and c:IsLink(g and #g or e:GetLabel())
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.spcost(e,tp,_,_,_,_,_,_,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,LOCATION_MZONE,nil)
	if chk==0 then return g:CheckSubGroup(s.gchk,1,3,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	e:SetLabel(Duel.SendtoGrave(g:SelectSubGroup(tp,s.gchk,false,1,3,e,tp),REASON_COST))
end
function s.sptg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:IsCostChecked() and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp),SUMMON_TYPE_LINK,tp,tp,true,false,POS_FACEUP)
end
