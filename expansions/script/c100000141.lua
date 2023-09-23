--Crystron Tap
--Attinzione Crystron
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Send 1 "Crystron" monster from your Deck to the GY, then you can send 1 "Crystron" card from your hand to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If you Synchro Summon a Machine Synchro Monster(s) (except during the Damage Step): You can banish this card from your GY;
	immediately after this effect resolves, Synchro Summon 1 Synchro Monster, using monsters you control as material,
	then you can Special Summon from your Extra Deck, 1 Machine Link Monster with a Link Rating equal to or lower than the number of "Crystron" monsters used as material for the Synchro Summon.
	(This is treated as a Link Summon.)]]
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabelObject(GYChk)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.tgfilter(c,chk)
	return c:IsSetCard(ARCHE_CRYSTRON) and (chk or c:IsMonster()) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsInGY() and Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND,0,1,nil,true) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g2=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,true)
		if #g2>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
	end
end

--E2
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsMonster(TYPE_SYNCHRO) and c:IsRace(RACE_MACHINE) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and (se==nil or c:GetReasonEffect()~=se)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.syncfilter(c)
	return c:IsSynchroSummonable(nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			local c=e:GetHandler()
			local sc=sg:GetFirst()
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e0:SetCode(EVENT_SPSUMMON_NEGATED)
			e0:SetOperation(function(E,TP,EG,EP,EV,RE,R,RP)
				if EG:IsContains(sc) then
					E:GetLabelObject():GetLabelObject():Reset()
					E:GetLabelObject():Reset()
					E:Reset()
				end
			end
			)
			Duel.RegisterEffect(e0,tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetLabel(0)
			e1:SetOperation(function(E,TP,EG,EP,EV,RE,R,RP)
				local C=E:GetHandler()
				local ct=E:GetLabel()
				if C:IsSummonType(SUMMON_TYPE_SYNCHRO) and ct>0 then
					if aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) and Duel.IsExists(false,s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
						local lc=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct):GetFirst()
						if lc then
							lc:SetMaterial(nil)
							if Duel.SpecialSummon(lc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
								lc:CompleteProcedure()
							end
						end
					end
				end
				E:Reset()
				e0:Reset()
			end
			)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
			sc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_MATERIAL_CHECK)
			e2:SetLabelObject(e1)
			e2:SetValue(s.matcheck)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
			sc:RegisterEffect(e2)
			--
			e0:SetLabelObject(e2)
			Duel.SynchroSummon(tp,sc,nil)
		end
	end
end
function s.lkfilter(c,e,tp,ct)
	return c:IsMonster(TYPE_LINK) and c:IsLinkBelow(ct) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function s.matfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_CRYSTRON)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(s.matfilter,nil)
	e:GetLabelObject():SetLabel(ct)
end