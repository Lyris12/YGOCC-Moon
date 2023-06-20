--Odette, Rosewhip Swan
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	Marionightte.Induct(c,100)
	--Proc
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(ref.spcon)
	c:RegisterEffect(e0)
	--Chain Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
ref.has_text_race=RACE_MACHINE+RACE_PLANT
function ref.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Marionightte.Is,tp,LOCATION_ONFIELD,0,1,nil)
end

--Chain Summon
function ref.ssfilter(c) return c:IsRace(RACE_PLANT+RACE_MACHINE) and c:IsSpecialSummonable() end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function ref.ssop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetLabelObject(g:GetFirst())
		e1:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetLabelObject()) end)
		e1:SetOperation(ref.thop)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_NEGATED)
		e2:SetLabelObject(e1)
		e2:SetLabel(g:GetFirst():GetFieldID())
		e2:SetCondition(function(e,tp,eg) return eg:IsContains(aux.FilterEqualFunction(Card.GetFieldID,e:GetLabel())) end)
		e2:SetOperation(function(e) e:GetLabelObject():Reset() e:Reset() end)
		Duel.RegisterEffect(e2,tp)
		Duel.SpecialSummonRule(tp,g:GetFirst())
	end
end
function ref.thfilter(c) return c:IsAbleToHand() and not c:IsCode(id) end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	local xc=e:GetLabelObject()
	if xc:IsLocation(LOCATION_MZONE) and xc:IsSummonType(TYPE_BIGBANG) then
		local mg=xc:GetMaterial():Filter(ref.thfilter,nil)
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Hint(HINT_CARD,1-tp,id)
				if Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,sg) end
			end
		end
	end
	e:Reset()
end
