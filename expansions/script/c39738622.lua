--Blastrize Reborn
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.filter1(c,e,tp)
	return c:IsSetCard(0x37e) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalAttribute())
		and Duel.GetMZoneCount(tp,c)>0
end
function cid.filter2(c,e,tp,att)
	return c:IsSetCard(0x37e) and c:IsType(TYPE_MONSTER) and c:GetOriginalAttribute()~=att and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local rg=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetOriginalAttribute())
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local att=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,att)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cid.sumlimit)
		e1:SetLabel(att)
		g:GetFirst():RegisterEffect(e1)
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	if bit.band(att,ATTRIBUTE_FIRE)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
	if bit.band(att,ATTRIBUTE_DIVINE)~=0 then
		g:GetFirst():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,6))
	  end   
   end
end
function cid.sumlimit(e,c)
	return c:IsAttribute(e:GetLabel())
end