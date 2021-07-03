--Chaos Fairy
function c160008888.initial_effect(c)   
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
   aux.AddEvoluteProc(c,nil,4,c160008888.filter1,2,2)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160008888,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c160008888.spcost)
	e1:SetOperation(c160008888.spop)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c160008888.val)
	c:RegisterEffect(e2)
	--Def
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
function c160008888.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_FAIRY)
end
function c160008888.val(e,c)
	local r=c:GetAttribute()
	if bit.band(r,ATTRIBUTE_DARK)>0 then return 500
	elseif bit.band(r,ATTRIBUTE_LIGHT)>0 then return -400
	else return 0 end
end
function c160008888.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsSummonable(true,nil)
end
function c160008888.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(160008888,tp,ACTIVITY_SPSUMMON)==0 and c:IsCanRemoveCounter(tp,0x88,3,REASON_COST) end
	c:RemoveCounter(tp,0x88,3,REASON_COST)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(c)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c160008888.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c160008888.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c.evolute and c~=e:GetLabelObject()
end
function c160008888.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c160008888.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c160008888.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c160008888.filter,tp,LOCATION_HAND,0,1,ft,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		Duel.Summon(tp,tc,true,nil)
		tc=g:GetNext()
	end
end
