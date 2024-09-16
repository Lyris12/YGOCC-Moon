--created by Slick, coded by Lyris
--The City of Belgrade
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	local e3=c:DriveEffect(0,aux.Stringid(id,0),CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_QUICK_O,nil,nil,s.spcon,nil,s.sptg,s.spop,true)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetLabelObject(e3)
	e4:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsEngaged))
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetCountLimit(1)
	e5:SetCost(s.cecost)
	e5:SetTarget(s.cetg)
	e5:SetOperation(s.ceop)
	c:RegisterEffect(e5)
end
function s.spcon(e)
	return e:GetHandler():IsEnergy(e:GetHandler():GetLevel())
end
function s.sptg(e,tp,_,_,_,_,_,_,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP) end
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function s.cecost(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_COST)
end
function s.cetg(e,tp,_,_,_,_,_,_,chk)
	local tc=Duel.GetEngagedCard(tp)
	if chk==0 then return tc and tc:IsCanIncreaseOrDecreaseEnergy(1,tp,REASON_EFFECT) end
end
function s.ceop(e,tp)
	local tc=Duel.GetEngagedCard(tp)
	if not tc then return end
	local t={}
	for _,i in ipairs{-2,-1,1,2} do if tc:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then table.insert(t,i) end end
	tc:UpdateEnergy(Duel.AnnounceNumber(tp,table.unpack(t)),tp,REASON_EFFECT)
	Duel.UpdateEnergyComplete()
end
