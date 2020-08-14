--created by Alastar Rainford, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_PZONE)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetCategory(CATEGORY_DEFCHANGE)
	e8:SetCondition(cid.pcon)
	e8:SetTarget(cid.ptg)
	e8:SetOperation(cid.pop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e9)
	local e7=e8:Clone()
	e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e7)
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),aux.NonTuner(cid.mfilter),1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,CARD_BLACK_GARDEN) end)
	e3:SetCost(cid.spcost3)
	e3:SetTarget(cid.sptg3)
	e3:SetOperation(cid.spop3)
	c:RegisterEffect(e3)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+100)
	e5:SetCondition(cid.pencon)
	e5:SetTarget(cid.pentg)
	e5:SetOperation(cid.penop)
	c:RegisterEffect(e5)
end
function cid.mfilter(c)
	return c:IsRace(RACE_PLANT) and not c:IsType(TYPE_EFFECT)
end
function cid.filter(c,e,tp)
	return c:GetSummonPlayer()==tp and c:IsRace(RACE_PLANT) and c:GetSummonLocation()==LOCATION_HAND and c:IsFaceup() and (not e or c:IsRelateToEffect(e))
end
function cid.pcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.filter,1,nil,nil,tp) and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,CARD_BLACK_GARDEN)
end
function cid.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function cid.pop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(cid.filter,1,nil,e,tp)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e1)
	end
end
function cid.costfilter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_PLANT) and not c:IsType(TYPE_EFFECT)
end
function cid.fgoal(sg,e,tp)
	local lv=sg:GetSum(Card.GetLevel)
	Duel.SetSelectedCard(sg)
	return Duel.CheckReleaseGroup(tp,nil,0,nil)
		and Duel.IsExistingMatchingCard(cid.spfilter3,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,lv,sg)
end
function cid.spfilter3(c,e,tp,lv,sg)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION) and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,0x1f) and c:CheckFusionMaterial()
		and (Duel.GetLocationCountFromEx(tp,tp,sg,c,0x1f)>0 or c:IsLocation(LOCATION_GRAVE))
end
function cid.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=(Duel.GetReleaseGroup(tp)+Duel.GetReleaseGroup(1-tp)):Filter(cid.costfilter,nil)
	if chk==0 then return rg:CheckSubGroup(cid.fgoal,2,#rg,e,tp) end
	local g=rg:SelectSubGroup(tp,cid.fgoal,false,2,#rg,e,tp)
	local lv=g:GetSum(Card.GetLevel)
	e:SetLabel(lv)
	Duel.Release(g,REASON_COST)
end
function cid.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function cid.spop3(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter3),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,lv,nil):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then tc:CompleteProcedure() end
	end
end
function cid.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_EFFECT+REASON_BATTLE~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function cid.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function cid.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
