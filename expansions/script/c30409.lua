--Zero HERO Cyclone Man
--Automate ID
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local scard=_G[str]
	local s_id=tonumber(string.sub(str,2))
	return scard,s_id
end

local scard,s_id=getID()

function scard.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,Card.IsZHERO,2,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(scard.atkval)
	c:RegisterEffect(e1)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(scard.condition)
	e1:SetTarget(scard.sptg)
	e1:SetOperation(scard.spop)
	c:RegisterEffect(e1)
	if not scard.global_check then
		scard.global_check=true
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		ge2:SetOperation(scard.archchk)
		Duel.RegisterEffect(ge2,0)
	end
end
function scard.archchk(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(0,30000)==0 then 
		Duel.CreateToken(tp,30000)
		Duel.CreateToken(1-tp,30000)
		Duel.RegisterFlagEffect(0,30000,0,0,0)
	end
end
function scard.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
function scard.nfilter(c)
	return c:IsFaceup() and not c:IsCode(s_id,21208154)
end
function scard.atkval(e,c)
	local ct=0
	local lk=e:GetHandler():GetLinkedGroup():Filter(scard.nfilter,nil)
	if lk:GetCount()<=0 then return end
	local tc=lk:GetFirst()
	for i=1,lk:GetCount() do
		local atk=tc:GetAttack()
		ct=ct+atk
		tc=lk:GetNext()
	end
	return ct
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
function scard.spfilter(c,e,tp,zone)
	return c:IsSetCard(8) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
		--[[ or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp,zone)]])
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	zone=e:GetHandler():GetLinkedZone()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(scard.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local zone=e:GetHandler():GetLinkedZone()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,scard.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		--temp disabled
		-- local choice=Duel.SelectOption(tp,aux.Stringid(s_id,0),aux.Stringid(s_id,1))
		-- if choice==0 then p=tp elseif choice==1 then p=1-tp end
		-- Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP_DEFENSE,zone)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
	end
end
