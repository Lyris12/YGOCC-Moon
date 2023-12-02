--[[
MAX Level Loan?!
Prestito Livello MAX?!
Card Author: greg501
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
    --[[Target 1 "LV" monster you control: banish it, then take 1 monster from your Deck that is mentioned on the banished monster and either Special Summon it, ignoring its Summoning Conditions,
	or send it to the GY and Special Summon a monster mentioned on it, ignoring its Summoning Conditions.
	During the End Phase, send the Summoned monster to the GY and return the banished monster to the field.]]
    local e1=Effect.CreateEffect(c)
	e1:Desc(0)
    e1:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetFunctions(nil,nil,s.target,s.activate)
    c:RegisterEffect(e1)
end
--E1
function s.filter(c,e,tp)
	if not (c:IsFaceup() and c:IsSetCard(ARCHE_LV) and c:IsAbleToRemove()) then return false end
	local code=c:GetOriginalCode()
	local class=_G["c"..code]
	if class==nil or class.lvup==nil then return false end
	return not e or Duel.IsExists(false,s.lvfilter1,tp,LOCATION_DECK,0,1,c,e,tp,c,class.lvup,false)
end
function s.lvfilter1(c,e,tp,oc,lvup,stop)
	if not c:IsCode(table.unpack(lvup)) or Duel.GetMZoneCount(tp,oc)<=0 then return false end
	if c:IsCanBeSpecialSummoned(e,0,tp,true,false) then
		return true
	elseif not stop and c:IsAbleToGrave() then
		local code=c:GetOriginalCode()
		local class=_G["c"..code]
		if class==nil or class.lvup==nil then return false end
		return Duel.IsExists(false,s.lvfilter1,tp,LOCATION_DECK,0,1,Group.FromCards(c,oc),e,tp,oc,class.lvup,true)
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,1,nil,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)>0 then
		local eid=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,3))
		local code=tc:GetOriginalCode()
		local class=_G["c"..code]
		if class==nil or class.lvup==nil then return end
		local g=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.lvfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil,class.lvup,false)
		if #g>0 then
			local lg=Group.FromCards(tc)
			local sc=g:GetFirst()
			code=sc:GetOriginalCode()
			class=_G["c"..code]
			local b1=sc:IsCanBeSpecialSummoned(e,0,tp,true,false)
			local b2=class~=nil and class.lvup~=nil and sc:IsAbleToGrave() and Duel.IsExists(false,s.lvfilter1,tp,LOCATION_DECK,0,1,sc,e,tp,nil,class.lvup,true)
			local opt=aux.Option(tp,id,1,b1,b2)
			if opt==0 then
				Duel.BreakEffect()
				if Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
					sc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,4))
					lg:AddCard(sc)
				end
			elseif opt==1 then
				Duel.BreakEffect()
				if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsInGY() then
					local tg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.lvfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil,class.lvup,true)
					if #tg>0 and Duel.SpecialSummon(tg,0,tp,tp,true,false,POS_FACEUP)>0 then
						local tgc=tg:GetFirst()
						tgc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,4))
						lg:AddCard(tgc)
					end
				end
			end
			
			if #lg==2 and tc:HasFlagEffectLabel(id,eid) then
				lg:KeepAlive()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCode(EVENT_PHASE|PHASE_END)
				e1:SetCountLimit(1)
				e1:SetLabel(eid)
				e1:SetLabelObject(lg)
				e1:SetCondition(s.tgcon)
				e1:SetOperation(s.tgop)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local eid=e:GetLabel()
	if not g:IsExists(Card.HasFlagEffectLabel,1,nil,id,eid) or not g:IsExists(Card.HasFlagEffectLabel,1,nil,id+100,eid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local eid=e:GetLabel()
	local rc=g:Filter(Card.HasFlagEffectLabel,nil,id,eid):GetFirst()
	local tc=g:Filter(Card.HasFlagEffectLabel,nil,id+100,eid):GetFirst()
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoGrave(tc,REASON_EFFECT)
	Duel.ReturnToField(rc)
	rc:ResetFlagEffect(id)
end