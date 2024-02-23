--[[
Zerost Soul Zerotl Anima
Essenza Zerost Anima Zerotl
Card Author: TopHatPenguin
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,3,true)
	--Gains 300 ATK/DEF for each banished card.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--[[If this card is Fusion Summoned using 3 monsters with different names: You can make both players choose 6 zones from their opponent's field and give them a number from 1 to 6,
	then both players roll a six-sided die and they must banish as many cards as possible from their field, that are in the zones with a number equal to or lower than their opponent's result.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_SINGLE)
	e2x:SetCode(EFFECT_MATERIAL_CHECK)
	e2x:SetValue(s.valcheck)
	e2x:SetLabelObject(e2)
	c:RegisterEffect(e2x)
	--If this card is banished: You can Special Summon it.
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:HOPT()
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.toss_dice = true

function s.matfilter(c)
	return c:IsFusionSetCard(ARCHE_ZEROTL) and c:IsLevelBelow(10)
end

--E1
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*300
end

--E2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1,g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0),Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then
		return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanRemove(1-tp)
			and (g1:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEUP,REASON_RULE) or g2:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEUP,REASON_RULE))
	end
	local g=g1+g2
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,0,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=Duel.GetTurnPlayer()
	local chosen={{},{}}
	local exczones={0,0}
	local emzg1,emzg2=Duel.GetMatchingGroup(Card.IsInEMZ,tp,LOCATION_MZONE,0,nil),Duel.GetMatchingGroup(Card.IsInEMZ,1-tp,LOCATION_MZONE,0,nil)
	if #emzg1+#emzg2==0 then
		local val=EXTRA_MONSTER_ZONE<<16
		exczones={val,val}
	else
		local val1,val2=EXTRA_MONSTER_ZONE,EXTRA_MONSTER_ZONE
		local nval1,nval2=0,0
		for tc in aux.Next(emzg1) do
			nval2=nval2|(tc:GetZone(tp)&EXTRA_MONSTER_ZONE)
		end
		for tc in aux.Next(emzg2) do
			nval1=nval1|(tc:GetZone(1-tp)&EXTRA_MONSTER_ZONE)
		end
		val1=(val1&(~nval1))<<16
		val2=(val2&(~nval2))<<16
		exczones={val1,val2}
	end
	for p=tp,1-tp,1-2*tp do
		Duel.SelectOption(p,aux.Stringid(id,2))
		for i=1,6 do
			local zones=Duel.SelectField(p,1,0,LOCATION_MZONE|LOCATION_SZONE,exczones[p+1],aux.Stringid(id,1+i))
			local g=Duel.GetMatchingGroup(s.zonefilter,p,0,LOCATION_ONFIELD,nil,p,zones)
			if #g>0 then
				Duel.HintSelection(g)
				g:GetFirst():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2+i))
			else
				if p==tp then
					Duel.Hint(HINT_ZONE,p,zones)
				else
					Duel.Hint(HINT_ZONE,tp,zones>>16)
				end
			end
			table.insert(chosen[p+1],zones)
			exczones[p+1]=exczones[p+1]|zones
		end
	end
	if not Duel.IsPlayerCanRemove(tp) or not Duel.IsPlayerCanRemove(1-tp) then return end
	Duel.BreakEffect()
	local res={Duel.TossDice(tp,1,1)}
	for p=tp,1-tp,1-2*tp do
		local dc=res[2-p]
		if Duel.IsPlayerCanRemove(p) and dc then
			local zones=0
			for i=1,dc do
				zones=zones|chosen[2-p][i]
			end
			local g=Duel.GetMatchingGroup(s.rmfilter,p,LOCATION_ONFIELD,0,nil,p,zones)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_RULE,p)
			end
		end
	end
end
function s.zonefilter(c,tp,zones)
	return c:GetZone(tp)&zones~=0
end
function s.rmfilter(c,tp,zones)
	return c:GetZone(1-tp)&zones~=0 and c:IsAbleToRemove(tp,POS_FACEUP,REASON_RULE)
end
function s.valcheck(e,c)
	local ce=e:GetLabelObject()
	local g=c:GetMaterial()
	if g and g:GetClassCount(Card.GetCode)==3 then
		ce:SetLabel(1)
	else
		ce:SetLabel(0)
	end
end

--E3
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end