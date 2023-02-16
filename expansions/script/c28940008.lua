--Gardrenial Cycle - Winter
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	Gardrenial.EnableTrackers(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
end

function ref.ssfilter(c,e,tp)
	return c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp,ref.anyfilter)
	if chk==0 then
		return (Gardrenial.NSPlant(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,Gardrenial.Code,TYPE_NORMAL,0,0,0,0,0))
			or (Gardrenial.NSInsect(tp) and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil))
	end
	if Gardrenial.NSPlant(tp) then Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED) end
	if Gardrenial.NSInsect(tp) then Duel.SetOperationInfo(0,CATEGORY_DISABLE,Duel.GetFieldGroup(tp,0,LOCATION_MZONE),1,0,0) end
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	local c=e:GetHandler()
	if Gardrenial.NSPlant(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,Gardrenial.Code,TYPE_NORMAL,0,0,0,0,0) then opt=opt+1 end
	if Gardrenial.NSInsect(tp) and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then opt=opt+2 end
	if opt==3 then opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)) end
	if opt==0 or opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
			Duel.SpecialSummonComplete()
			if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,Gardrenial.Code,TYPE_NORMAL,0,0,0,tc:GetRace(),0) then
				c:AddMonsterAttribute(TYPE_NORMAL,0,tc:GetRace())
				if tc:HasLevel() then
					local e8=Effect.CreateEffect(c)
					e8:SetType(EFFECT_TYPE_SINGLE)
					e8:SetCode(EFFECT_CHANGE_LEVEL)
					e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e8:SetReset(RESET_EVENT+0x47c0000)
					e8:SetValue(tc:GetLevel())
				else c:SetStatus(STATUS_NO_LEVEL,true) end
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	if opt==0 or opt==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+0x1fc0000)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e2:SetType(EFFECT_TYPE_IGNITION)
			e2:SetRange(LOCATION_SZONE)
			e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
				Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST,nil)
			end)
			e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_SZONE)
			end)
			e2:SetOperation(function(e,tp) local c=e:GetHandler()
				if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
					Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
				end
			end)
			e2:SetReset(RESET_EVENT+0x1fc0000)
			tc:RegisterEffect(e2)
			if Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
				Duel.MoveToField(tc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	end
end
