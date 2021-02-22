--ヒーローハート
function c9945305.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9945305)
	e1:SetTarget(c9945305.target)
	e1:SetOperation(c9945305.operation)
	c:RegisterEffect(e1)
end
function c9945305.thfilter(c)
	return c:IsLevelAbove(2) and c:IsFaceup() and c:IsSetCard(0x204F)
end
function c9945305.spfilter2(c,e,tp)
	return c:IsSetCard(0x204F) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c9945305.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9945305.thfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c9945305.thfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
	and Duel.IsExistingMatchingCard(c9945305.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c9945305.thfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c9945305.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
	local lv=tc:GetLevel()
		if (lv - math.floor(lv/2)*2)==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(lv/2)
		tc:RegisterEffect(e1)
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9945305.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
			Duel.BreakEffect()
			local ssg=sg:GetFirst()		
			if ssg and Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			ssg:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+0x1fe0000)
			ssg:RegisterEffect(e3)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CHANGE_LEVEL)
			e4:SetValue(lv/2)
			e4:SetReset(RESET_EVENT+0x1fe0000)
			ssg:RegisterEffect(e4)
		end
		end
		else
			local e5=Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_CHANGE_LEVEL)
			e5:SetReset(RESET_EVENT+0x1fe0000)
			e5:SetValue(lv/2+(1/2))
			tc:RegisterEffect(e5)
			if tc:IsRelateToEffect(e) and tc:IsFaceup() then
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9945305.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
				Duel.BreakEffect()
				local ssg=sg:GetFirst()
				if ssg and Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)>0 then
				local e6=Effect.CreateEffect(c)
				e6:SetType(EFFECT_TYPE_SINGLE)
				e6:SetCode(EFFECT_DISABLE)
				e6:SetReset(RESET_EVENT+0x1fe0000)
				ssg:RegisterEffect(e6)
				local e7=Effect.CreateEffect(c)
				e7:SetType(EFFECT_TYPE_SINGLE)
				e7:SetCode(EFFECT_DISABLE_EFFECT)
				e7:SetReset(RESET_EVENT+0x1fe0000)
				ssg:RegisterEffect(e7)
				local e8=Effect.CreateEffect(c)
				e8:SetType(EFFECT_TYPE_SINGLE)
				e8:SetCode(EFFECT_CHANGE_LEVEL)
				e8:SetValue(lv/2+(1/2))
				e8:SetReset(RESET_EVENT+0x1fe0000)
				ssg:RegisterEffect(e8)	
				end
			end
		end
	end
end
