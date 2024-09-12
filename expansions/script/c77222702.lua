--Anbionic Tester
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can Special Summon 1 "Spinup Token" (Thunder/LIGHT/Level 1/1000 ATK/0 DEF) or 1 "Spindown Token" (Thunder/LIGHT/Level 1/0 ATK/1000 DEF).
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--If this card on the field is destroyed: You can send 1 "Anbionic" card from your Deck to the GY, except "Anbionic Tester". 
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsPlayerCanSpecialSummonMonster(tp,177222703,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT) or 
		Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op1=Duel.IsPlayerCanSpecialSummonMonster(tp,177222703,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	local op2=Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (op1 or op2) then
		local finalop=0
		if(op1 and op2) then
			finalop=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		elseif(not op1) then
			finalop=1
		end
		if(finalop==0) then
			local tk=Duel.CreateToken(tp,177222703)
			if(Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_DESTROYED)
				e1:SetCondition(s.drawcon)
				e1:SetOperation(s.drawop)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_DESTROY)
				e2:SetLabelObject(e1)
				e2:SetOperation(s.checkop)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tk:RegisterEffect(e2)
				tk:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
			end
			Duel.SpecialSummonComplete()
		else
			local tk=Duel.CreateToken(tp,177222704)
			if(Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_DESTROYED)
				e1:SetCondition(s.drawcon)
				e1:SetOperation(s.drawop)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_DESTROY)
				e2:SetLabelObject(e1)
				e2:SetOperation(s.checkop)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tk:RegisterEffect(e2)
				tk:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:SetLabel(1)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	e:SetLabel(0)
	e:Reset()
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.filter(c)
	return c:IsSetCard(0xe57) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end