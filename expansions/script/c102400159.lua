--created & coded by Lyris, art on Reddit at https://www.reddit.com/r/yugioh/comments/88lik5/fan_art_cyber_dragon/
--Cyber Dragon Ein
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.TRUE,2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetOperation(s.matcheck)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetLabelObject(e1)
	e3:SetCondition(s.con)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetLabelObject(e1)
	e4:SetCondition(aux.NOT(s.con))
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	aux.EnableChangeCode(c,CARD_CYBER_DRAGON,LOCATION_GRAVE+LOCATION_MZONE,aux.NOT(s.con))
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetLabelObject(e1)
	e5:SetCondition(s.fcon)
	e5:SetTarget(s.tg)
	c:RegisterEffect(e5)
end
function s.matcheck(e,c)
	e:SetLabel(c:GetMaterial():IsExists(Card.IsSetCard,1,nil,0x1093) and 1 or 0)
end
function s.con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabelObject():GetLabel()<1
end
function s.fcon(e)
	return not s.con(e) and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c)
	return c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToHand()
end
function s.rfilter(c)
	local e=c:CheckActivateEffect(c,true,true,false)
	return (c:IsCode(1020101,102400002,3659803,37630732,55704856) or aux.IsCodeListed(c,CARD_CYBER_DRAGON)
		or aux.IsSetNameMonsterListed(0x1093)) and c:IsAbleToRemove() and e
		and e:IsHasCategory(CATEGORY_FUSION_SUMMON) and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local t={b1 and 1191,b2 and 1192}
	local v={}
	for j=0,#t-1 do table.insert(v,j) end
	for i=#t,1,-1 do if not t[i] then table.remove(t,i) table.remove(v,i) end end
	local opt=v[Duel.SelectOption(tp,table.unpack(t))+1]
	if opt<1 then
		e:SetCategory(CATEGORY_GRAVE_ACTION+CATEGORY_TOHAND+CATEGORY_TODECK)
		e:SetOperation(s.thop)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_REMOVE)
		e:SetOperation(s.rmop)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,99,nil)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)<=0 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct,ct,nil),nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.rmop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
		for _,e in ipairs{c:GetActivateEffect()} do
			if e:IsHasCategory(CATEGORY_FUSION_SUMMON) then e:GetOperation()(e,tp) break end
		end
	end
end
