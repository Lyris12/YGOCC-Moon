--[[
D.D. Mirrorverse Dragon
D.D. Drago Specchioverso
Card Author: Slick
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--If you and your opponent both have a card with the same name on your respective field, GY or banishment, and both cards are in the same location (field, GY or banishment): You can Special Summon this card from your hand or GY, but banish it when it leaves the field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--You can only control 1 "D.D. Mirrorverse Dragon".
	c:SetUniqueOnField(1,0,id)
	--When another monster's effect is activated (Quick Effect): You can make this card's name, Attribute, and Type become the same as that monster's until the end of this turn, and if you do, this card gains that monster's effects until the end of this turn, then if it was an opponent's monster, you can negate the activation.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.copycon,nil,s.copytg,s.copyop)
	c:RegisterEffect(e2)
end
--E1
function s.gcheck(g)
	local c1,c2=g:GetFirst(),g:GetNext()
	local loc1,loc2=c1:GetLocation(),c2:GetLocation()
	return c1:IsCode(c2:GetCode()) and c1:GetControler()~=c2:GetControler() and (loc1==loc2 or (loc1&LOCATION_ONFIELD>0 and loc2&LOCATION_ONFIELD>0))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsFaceupEx,tp,LOCATION_ONFIELD|LOCATION_GB,LOCATION_ONFIELD|LOCATION_GB,nil)
	return g:CheckSubGroup(s.gcheck,2,2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
end

--E2
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.checkname(c,rc)
	local codes,rcodes={c:GetCode()},{rc:GetCode()}
	for _,code in ipairs(codes) do
		for _,rcode in ipairs(rcodes) do
			if code~=rcode then
				return true
			end
		end
	end
	return false
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		local c=e:GetHandler()
		return rc:IsRelateToChain(ev) and (rc:IsFaceup() or not c:IsOnField())
			and (rc:GetAttribute()~=c:GetAttribute()
			or rc:GetRace()~=c:GetRace()
			or s.checkname(c,rc))
	end
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER)
	if p==1-tp then
		e:SetCategory(CATEGORY_NEGATE)
		Duel.SetTargetParam(1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	else
		Duel.SetTargetParam(0)
		e:SetCategory(0)
	end
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() or not rc:IsRelateToChain(ev) or not (rc:IsFaceup() or not c:IsOnField()) then return end
	local check=false
	local codes,attr,race={rc:GetCode()},rc:GetAttribute(),rc:GetRace()
	if codes[1]~=c:GetCode() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(codes[1])
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		if c:RegisterEffect(e1) and not check and not c:IsImmuneToEffect(e1) then
			check=true
		end
	end
	if #codes>1 and codes[2]~=c:GetCode() then
		local ecode=check and EFFECT_ADD_CODE or EFFECT_CHANGE_CODE
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(ecode)
		e2:SetValue(codes[2])
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		if c:RegisterEffect(e2) and not check and not c:IsImmuneToEffect(e2) then
			check=true
		end
	end
	if attr~=c:GetAttribute() then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(attr)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		if c:RegisterEffect(e3) and not check and not c:IsImmuneToEffect(e3) then
			check=true
		end
	end
	if race~=c:GetRace() then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(race)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		if c:RegisterEffect(e4) and not check and not c:IsImmuneToEffect(e4) then
			check=true
		end
	end
	if check and c:CopyEffect(rc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,1) and Duel.GetTargetParam()==1 and Duel.IsChainNegatable(ev) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.NegateActivation(ev)
	end
end