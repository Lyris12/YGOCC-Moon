--Idol Echopalco
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cid.atktg)
	e2:SetValue(cid.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--echo token
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(cid.tkcon)
	e4:SetCost(cid.tkcost)
	e4:SetTarget(cid.tktg)
	e4:SetOperation(cid.tkop)
	c:RegisterEffect(e4)
	--swarm field with tokens
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(cid.tkcon2)
	e5:SetTarget(cid.tktg2)
	e5:SetOperation(cid.tkop2)
	c:RegisterEffect(e5)
end
--ATK/DEF
--filters
function cid.atkfilter(c,cc)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAttribute(cc:GetAttribute()) and c:GetLevel()<cc:GetLevel()
end
function cid.doubtfilter(c)
	return c:IsFacedown() or c:IsType(TYPE_MONSTER)
end
function cid.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),0,0x4011,c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())
end
function cid.tkconfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
		and not Duel.IsExistingMatchingCard(cid.excfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel())
end
function cid.excfilter(c,lv)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetLevel()>lv
end
---------
function cid.atktg(e,c)
	local g=Duel.GetFieldGroup(c:GetControler(),LOCATION_MZONE,0)
	return c:IsType(TYPE_MONSTER) and g:GetMaxGroup(Card.GetLevel):IsContains(c)
end
function cid.atkval(e,c)
	return Duel.GetMatchingGroupCount(cid.atkfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c,c)*300
end
--ECHO TOKEN 1
function cid.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cid.doubtfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
	end
	e:SetLabel(0)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		Duel.SetTargetCard(g)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	end
end
function cid.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute()) then return end
	local token=Duel.CreateToken(tp,8017250)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetTextAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetTextDefense())
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetOriginalLevel())
		token:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetOriginalRace())
		token:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetOriginalAttribute())
		token:RegisterEffect(e5)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CHANGE_CODE)
		e6:SetValue(tc:GetOriginalCode())
		token:RegisterEffect(e6)
		Duel.SpecialSummonComplete()
	end
end
--SWARM FIELD
function cid.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.tkconfilter,1,nil,tp)
end
function cid.tktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(cid.tkconfilter,nil,tp)
		if #g<=0 then return false end
		local check=false
		local tc=g:GetFirst()
		while tc do
			if Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute(),POS_FACEUP_ATTACK,tp) 
			or Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute(),POS_FACEUP_ATTACK,1-tp) then
				check=true
			end
			tc=g:GetNext()
		end
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0) and check 
	end
	local g=eg:Filter(cid.tkconfilter,nil,tp)
	if #g<=0 then return end
	local group=Group.CreateGroup()
	group:KeepAlive()
	local tc=g:GetFirst()
	while tc do
		if Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute(),POS_FACEUP_ATTACK,tp) 
		or Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute(),POS_FACEUP_ATTACK,1-tp) then
			group:AddCard(tc)
		end
		tc=g:GetNext()
	end
	if #group>0 then
		if #group>1 then
			local sel=group:Select(tp,1,1,nil)
			Duel.HintSelection(sel)
			Duel.SetTargetCard(sel)
		else
			Duel.SetTargetCard(g)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,0,PLAYER_ALL,0)
	end
end
function cid.tkop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetLevel()
	if ct<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	repeat
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute(),POS_FACEUP_ATTACK,tp)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),0,0x4011,tc:GetTextAttack(),tc:GetTextDefense(),tc:GetOriginalLevel(),tc:GetOriginalRace(),tc:GetOriginalAttribute(),POS_FACEUP_ATTACK,1-tp)
		if not (b1 or b2) then break end
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(99092624,1),aux.Stringid(99092624,2))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(99092624,1))
		else
			op=Duel.SelectOption(tp,aux.Stringid(99092624,2))+1
		end
		local p=tp
		if op>0 then p=1-tp end
		local token=Duel.CreateToken(tp,8017250)
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP_ATTACK)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetTextAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetTextDefense())
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetOriginalLevel())
		token:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetOriginalRace())
		token:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetOriginalAttribute())
		token:RegisterEffect(e5)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CHANGE_CODE)
		e6:SetValue(tc:GetOriginalCode())
		token:RegisterEffect(e6)
		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_SINGLE)
		e7:SetCode(EFFECT_UNRELEASABLE_SUM)
		e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e7:SetReset(RESET_EVENT+RESETS_STANDARD)
		e7:SetValue(1)
		token:RegisterEffect(e7,true)
		local e8=e7:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		token:RegisterEffect(e8,true)
		local e9=e7:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		token:RegisterEffect(e9,true)
		local e10=e7:Clone()
		e10:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		token:RegisterEffect(e10,true)
		local e11=e7:Clone()
		e11:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		token:RegisterEffect(e11,true)
		local e12=e7:Clone()
		e12:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
		token:RegisterEffect(e12,true)
		local e13=e7:Clone()
		e13:SetCode(EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)
		token:RegisterEffect(e13,true)
		local e14=e7:Clone()
		e14:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
		token:RegisterEffect(e14,true)
		local e15=e7:Clone()
		e15:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		token:RegisterEffect(e15,true)
		ct=ct-1
	until ct==0 or not Duel.SelectYesNo(tp,aux.Stringid(99092624,0))
	Duel.SpecialSummonComplete()
end