--Temporius the Time Traveler
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be used as material for the Special Summon of a monster from the Extra Deck, except for a Time Leap Monster.
	aux.CannotBeEDMaterial(c,s.matlimit,nil)
	--If a Time Leap Monster leaves the field while this card is banished or in your hand: You can Special Summon this card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can declare a Level from 1 to 8, a Type and/or an Attribute; until the end of this turn, this card becomes the declared Level, Type and Attribute.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.matlimit(c)
	return c:IsType(TYPE_TIMELEAP)
end
function s.cfilter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_TIMELEAP~=0 and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp,rp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local declared=0
	local c=e:GetHandler()
	local lv=e:GetHandler():GetLevel()
	local rc=e:GetHandler():GetRace()
	local att=e:GetHandler():GetAttribute()
	local newlv,newrc,newatt=0
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		newlv=Duel.AnnounceLevel(tp,1,8,lv)
		declared = declared+1
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		newrc=Duel.AnnounceRace(tp,1,RACE_ALL-rc)
		declared = declared+1
	end
	if declared==0 or Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		newatt=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL-att)
	end
	e:SetLabel(newlv,newrc,newatt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local newlv,newrc,newatt=e:GetLabel()
	if newlv~=0 and c:GetLevel()~=newlv then
		--Change level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(newlv)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
	if newrc~=0 and c:GetRace()~=newrc then
		--Change type
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e2:SetValue(newrc)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e2)
	end
	if newatt~=0 and c:GetAttribute()~=newatt then
		--Change Attribute
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e3:SetValue(newatt)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e3)
	end
end