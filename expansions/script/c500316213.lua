--Corrupted hyena of Evil Vine
function c500316213.initial_effect(c)
	 --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c500316213.spcon)
	c:RegisterEffect(e1)
		--token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(500316213,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,500316213)
	e2:SetCondition(c500316213.tkcon)
	e2:SetTarget(c500316213.tktg)
	e2:SetOperation(c500316213.tkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
			--lv change
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(500316213,2))
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,500316213)
	e6:SetTarget(c500316213.target)
	e6:SetOperation(c500316213.operation)
	c:RegisterEffect(e6)
 
end
function c500316213.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x485a) and c:GetCode()~=500316213
end
function c500316213.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c500316213.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c500316213.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL and re==e:GetLabelObject() 
end
function c500316213.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	  if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,500314033,0x485a,0x4011,0,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function c500316213.tkop(e,tp,eg,ep,ev,re,r,rp)
	 local c=e:GetHandler()
   if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,500314033,0x485a,0x4011,0,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
		for i=1,2 do
			local token=Duel.CreateToken(tp,500314033)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			 local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetValue(c500316213.synlimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)
			
		end
		Duel.SpecialSummonComplete()
				 local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetTargetRange(1,0)
		e0:SetTarget(c500316213.splimit)
		e0:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e0,tp)
	end
end
function c500316213.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x485a)
end
function c500316213.splimit(e,c)
	return not c:IsSetCard(0x485a)
end
function c500316213.xfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x285a) and c:IsLevelAbove(1)
end
function c500316213.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c500316213.xfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c500316213.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c500316213.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)

end
function c500316213.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-2) 
		tc:RegisterEffect(e1)
end
end